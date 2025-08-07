//
//  AppState.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI
import Combine
import CoreLocation
import Foundation

/// Manages the global state of the application.
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @AppStorage("selectedTheme") var selectedTheme: String = Theme.system.rawValue
    @AppStorage("maxDurationPreference") var maxDurationPreference: Int = 15
    
    @Published var allPacks: [PromptPack] = []
    @Published var activePackIDs: Set<UUID> = []
    @Published var lastActivePackIDs: Set<UUID> = []
    @Published var promptHistory: [UUID] = []
    @Published var favoritePromptIDs: Set<UUID> = []
    
    /// Location manager for handling location-based features
    let locationManager = LocationManager.shared
    
    /// Home location and status
    @Published var homeLocation: CLLocation?
    @Published var isAtHome: Bool? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up location manager to trigger AppState updates
        locationManager.$isAtHome
            .receive(on: DispatchQueue.main)
            .assign(to: \.isAtHome, on: self)
            .store(in: &cancellables)
        
        locationManager.$homeLocation
            .receive(on: DispatchQueue.main)
            .assign(to: \.homeLocation, on: self)
            .store(in: &cancellables)
    }
    
    func configureHome(at coordinate: CLLocationCoordinate2D) {
        homeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        locationManager.startGeofenceMonitoring(at: coordinate)
    }
    
    func requestLocationAccess() {
        locationManager.requestPermissions()
    }
    
    /// Provides a preview state for SwiftUI Previews.
    static func previewState() -> AppState {
        let state = AppState()
        state.allPacks = QuestPackLoader.loadPacks()
        if let firstPackID = state.allPacks.first?.id {
            state.activePackIDs = [firstPackID]
        }
        return state
    }
}

// MARK: - Shared Storage Helper
extension AppState {
    func saveLatestPrompt(_ prompt: Prompt) {
        guard let data = try? JSONEncoder().encode(prompt) else { return }
        UserDefaults(suiteName: Shared.appGroupID)?
            .set(data, forKey: Shared.latestPromptKey)
    }

    func loadLatestPrompt() -> Prompt? {
        return SharedStorageHelper.loadLatestPrompt()
    }
}
