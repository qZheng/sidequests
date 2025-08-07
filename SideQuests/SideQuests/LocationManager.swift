import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let homeRegionIdentifier = "homeRegion"
    private let homeRegionRadius: CLLocationDistance = 500 // meters
    
    @Published var isAtHome: Bool? = nil
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var homeLocation: CLLocation?
    @Published var error: LocationError?
    
    private override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        loadHomeLocation()
    }
    
    deinit {
        locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
    }
    
    func requestPermissions() {
        // Ask for Always permission
        locationManager.requestAlwaysAuthorization()
    }
    
    func setHomeLocationToCurrent() async throws -> CLLocation {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationError.permissionDenied
        }
        
        error = nil
        
        return try await withCheckedThrowingContinuation { continuation in
            locationManager.requestLocation()
            
            // Store continuation to be called in delegate method
            self.locationRequestContinuation = continuation
            
            // Set up timeout
            Task {
                try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds timeout
                if let storedContinuation = self.locationRequestContinuation {
                    self.locationRequestContinuation = nil
                    storedContinuation.resume(throwing: LocationError.locationFailed(NSError(domain: "LocationManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location request timed out"])))
                }
            }
        }
    }
    
    func startGeofenceMonitoring(at homeCoordinate: CLLocationCoordinate2D) {
        // Stop any old regions
        locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
        
        // Define the home region
        let region = CLCircularRegion(
            center: homeCoordinate,
            radius: homeRegionRadius,
            identifier: homeRegionIdentifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        // Start monitoring
        locationManager.startMonitoring(for: region)
        // Immediately ask for current state
        locationManager.requestState(for: region)
        
        // Save home location
        let location = CLLocation(latitude: homeCoordinate.latitude, longitude: homeCoordinate.longitude)
        homeLocation = location
        saveHomeLocation()
    }
    
    func clearHomeLocation() {
        homeLocation = nil
        isAtHome = nil
        locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
        saveHomeLocation()
    }
    
    // MARK: - Private Methods
    
    private func loadHomeLocation() {
        guard let data = UserDefaults.standard.data(forKey: "homeLocation") else { return }
        
        do {
            let location = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data)
            homeLocation = location
            if let coordinate = location?.coordinate {
                startGeofenceMonitoring(at: coordinate)
            }
        } catch {
            print("Failed to load home location: \(error)")
            UserDefaults.standard.removeObject(forKey: "homeLocation")
        }
    }
    
    private func saveHomeLocation() {
        if let homeLocation = homeLocation {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: homeLocation, requiringSecureCoding: true)
                UserDefaults.standard.set(data, forKey: "homeLocation")
            } catch {
                print("Failed to save home location: \(error)")
            }
        } else {
            UserDefaults.standard.removeObject(forKey: "homeLocation")
        }
    }
    
    // MARK: - Continuation Storage
    
    private var locationRequestContinuation: CheckedContinuation<CLLocation, Error>?
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways {
            // Re-start monitoring if we already have a home location
            if let homeLocation = homeLocation {
                startGeofenceMonitoring(at: homeLocation.coordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // If this was a one-time location request for setting home location
        if let continuation = locationRequestContinuation {
            locationRequestContinuation = nil
            startGeofenceMonitoring(at: location.coordinate)
            continuation.resume(returning: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier == homeRegionIdentifier else { return }
        isAtHome = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region.identifier == homeRegionIdentifier else { return }
        isAtHome = false
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region.identifier == homeRegionIdentifier else { return }
        switch state {
        case .inside:
            isAtHome = true
        case .outside, .unknown:
            isAtHome = false
        @unknown default:
            isAtHome = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Geofence monitoring failed:", error.localizedDescription)
        self.error = .monitoringFailed(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CoreLocation error:", error.localizedDescription)
        
        // Handle the continuation if this was a one-time location request
        if let continuation = locationRequestContinuation {
            locationRequestContinuation = nil
            continuation.resume(throwing: LocationError.locationFailed(error))
        } else {
            self.error = .locationFailed(error)
        }
    }
}

// MARK: - LocationError

/// Errors that can occur during location operations
enum LocationError: LocalizedError {
    case permissionDenied
    case locationFailed(Error)
    case monitoringFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission is required to use this feature"
        case .locationFailed(let error):
            return "Failed to get location: \(error.localizedDescription)"
        case .monitoringFailed(let error):
            return "Failed to monitor location: \(error.localizedDescription)"
        }
    }
}
