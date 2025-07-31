//
//  SettingsView.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var useLocationFiltering = true
    @State private var useWeatherData = true
    @State private var filterByTimeOfDay = true
    @State private var dailyNotifications = false
    @State private var notificationTime = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Context Awareness")) {
                    Toggle("Use location filtering", isOn: $useLocationFiltering)
                    Toggle("Use weather data", isOn: $useWeatherData)
                    Toggle("Filter by time of day", isOn: $filterByTimeOfDay)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Daily prompt reminder", isOn: $dailyNotifications)
                    if dailyNotifications {
                        DatePicker("Reminder time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Prompt Preferences")) {
                    HStack {
                        Text("Max quest time:")
                        Spacer()
                        Picker("Max quest time", selection: $appState.maxDurationPreference) {
                            ForEach(5...60, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(width: 80, height: 40)
                        .clipped()
                        Text("min")
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appState.selectedTheme) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                }

                Section(header: Text("Premium")) {
                    Button("Unlock Premium Packs") {
                        // TODO: Show purchase screen
                    }
                }
                
                Section(header: Text("Data & Privacy")) {
                    Button("Clear prompt history") {
                        appState.promptHistory.removeAll()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState.previewState())
    }
}
