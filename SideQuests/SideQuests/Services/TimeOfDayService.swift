import Foundation
import Combine
import CoreLocation
import Solar

@MainActor
final class TimeOfDayService: ObservableObject {
    static let shared = TimeOfDayService()

    /// Exposes the current period so you can filter prompts
    @Published private(set) var current: TimeOfDay = .day

    private var timer: Timer?
    private let locationManager = LocationManager.shared
    private var clockChangeCancellable: AnyCancellable?

    private init() {
        // Wait for a valid location then kick off
        Task { await self.bootstrap() }
        
        // Handle clock changes (DST, manual time changes, etc.)
        clockChangeCancellable = NotificationCenter.default.publisher(for: .NSSystemClockDidChange)
            .sink { [weak self] _ in
                Task { [weak self] in
                    self?.updateAndSchedule()
                }
            }
    }

    private func bootstrap() async {
        // 1) Wait for home location to be set
        while locationManager.homeLocation == nil {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        updateAndSchedule()
    }

    private func updateAndSchedule() {
        computeCurrentTOD()
        scheduleNextBoundary()
    }

    private func computeCurrentTOD() {
        guard
          let coord = locationManager.homeLocation?.coordinate,
          let solar = Solar(for: Date(), coordinate: coord),
          let sunrise = solar.sunrise,
          let sunset = solar.sunset
        else {
          current = .day; return
        }

        let now = Date()
        switch now {
        case sunrise ... sunset:
          current = .day
        case (sunrise - 3600) ... sunrise:
          current = .sunrise
        case sunset ... (sunset + 3600):
          current = .sunset
        default:
          current = .night
        }
    }

    private func scheduleNextBoundary() {
        guard
          let coord = locationManager.homeLocation?.coordinate,
          let solar = Solar(for: Date(), coordinate: coord),
          let sunrise = solar.sunrise,
          let sunset = solar.sunset
        else { return }

        let boundaries: [Date] = [
          sunrise.addingTimeInterval(-3600),
          sunrise,
          sunset,
          sunset.addingTimeInterval(3600)
        ].filter { $0 > Date() }

        guard let next = boundaries.min() else { return }
        let interval = next.timeIntervalSinceNow + 1

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { [weak self] in
                self?.updateAndSchedule()
            }
        }
    }
} 