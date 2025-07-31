//
//  MainTabView.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Quests", systemImage: "sparkles")
                }

            PacksView()
                .tabItem {
                    Label("Quest Packs", systemImage: "books.vertical")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(appState)
        .preferredColorScheme((Theme(rawValue: appState.selectedTheme) ?? .system).colorScheme)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppState.previewState())
    }
}
