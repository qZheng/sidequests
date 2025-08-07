//
//  SettingsView.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("useLocationFiltering") private var useLocationFiltering = true
    @AppStorage("filterByTimeOfDay") private var filterByTimeOfDay = true
    @State private var useWeatherData = false
    @State private var dailyNotifications = false
    @State private var notificationTime = Date()
    @State private var isSettingHome = false
    @State private var showingLocationAlert = false
    @State private var locationAlertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                locationSection
                notificationsSection
                promptPreferencesSection
                appearanceSection
                premiumSection
                dataPrivacySection
                aboutSection
            }
            .navigationTitle("Settings")
            .alert("Location Error", isPresented: $showingLocationAlert) {
                Button("OK") { }
            } message: {
                Text(locationAlertMessage)
            }
        }
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        Section(header: Text("Context Awareness")) {
            Toggle("Use location filtering", isOn: $useLocationFiltering)
            
            if useLocationFiltering {
                locationStatusView
            }
            
            Toggle("Use weather data", isOn: $useWeatherData)
                .disabled(true)
            Toggle("Filter by time of day", isOn: $filterByTimeOfDay)
        }
        .onChange(of: useLocationFiltering) { isOn in
            if !isOn {
                appState.locationManager.clearHomeLocation()
            }
        }
    }
    
    private var locationStatusView: some View {
        Group {
            if appState.homeLocation == nil {
                if isSettingHome {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Setting home location...")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Button("Set Home to Current Location") {
                        Task {
                            await handleSetHomeAction()
                        }
                    }
                }
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Home Location Set")
                            .font(.subheadline)
                        if let isAtHome = appState.isAtHome {
                            Text(isAtHome ? "🏠 Currently at home" : "🚶‍♂️ Currently away from home")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Determining home status...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button("Clear") {
                        appState.locationManager.clearHomeLocation()
                    }
                    .foregroundColor(.red)
                }
            }
            
            locationPermissionStatus
        }
    }
    
    private var locationPermissionStatus: some View {
        Group {
            switch appState.locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                Text("To enable automatic home detection when the app is in the background, please grant 'Always' location access in Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                Button("Grant Always Access") {
                    appState.locationManager.requestPermissions()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
            case .denied, .restricted:
                Text("Location access is denied. Please grant access in Settings to use this feature.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                Button("Open Settings") {
                    openAppSettings()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
            case .notDetermined:
                Text("Location permission is required to use location-based features.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
            case .authorizedAlways:
                EmptyView()
                
            @unknown default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Other Sections
    
    private var notificationsSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Daily prompt reminder", isOn: $dailyNotifications)
            if dailyNotifications {
                DatePicker("Reminder time", selection: $notificationTime, displayedComponents: .hourAndMinute)
            }
        }
    }
    
    private var promptPreferencesSection: some View {
        Section(header: Text("Prompt Preferences")) {
            Picker("Max quest time", selection: $appState.maxDurationPreference) {
                ForEach([5, 10, 15, 30, 60], id: \.self) { minute in
                    Text("\(minute) min").tag(minute)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private var appearanceSection: some View {
        Section(header: Text("Appearance")) {
            Picker("Theme", selection: $appState.selectedTheme) {
                ForEach(Theme.allCases) { theme in
                    Text(theme.rawValue).tag(theme.rawValue)
                }
            }
        }
    }
    
    private var premiumSection: some View {
        Section(header: Text("Premium")) {
            Button("Unlock Premium Packs") {
                // TODO: Show purchase screen
            }
        }
    }
    
    private var dataPrivacySection: some View {
        Section(header: Text("Data & Privacy")) {
            Button("Clear prompt history") {
                appState.promptHistory.removeAll()
            }
            .foregroundColor(.red)
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleSetHomeAction() async {
        isSettingHome = true
        
        do {
            switch appState.locationManager.authorizationStatus {
            case .notDetermined:
                appState.locationManager.requestPermissions()
                // Wait a bit for the user to respond to the permission request
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                
                // Check if permission was granted
                if appState.locationManager.authorizationStatus == .authorizedWhenInUse || appState.locationManager.authorizationStatus == .authorizedAlways {
                    let location = try await appState.locationManager.setHomeLocationToCurrent()
                    appState.configureHome(at: location.coordinate)
                } else {
                    showLocationAlert("Location permission is required to set your home location.")
                }
                
            case .authorizedWhenInUse, .authorizedAlways:
                let location = try await appState.locationManager.setHomeLocationToCurrent()
                appState.configureHome(at: location.coordinate)
                
            case .denied, .restricted:
                showLocationAlert("Location access is denied. Please grant access in Settings to use this feature.")
                
            @unknown default:
                showLocationAlert("Unknown location authorization status.")
            }
        } catch {
            showLocationAlert(error.localizedDescription)
        }
        
        isSettingHome = false
    }
    
    private func showLocationAlert(_ message: String) {
        locationAlertMessage = message
        showingLocationAlert = true
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState.previewState())
    }
}
