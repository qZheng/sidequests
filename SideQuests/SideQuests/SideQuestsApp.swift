//
//  SideQuestsApp.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

@main
struct SideQuestsApp: App {
    @StateObject private var appState = AppState()

    init() {
        let state = AppState()
        state.allPacks = QuestPackLoader.loadPacks()
        // Activate the first pack by default
        if let firstPack = state.allPacks.first {
            state.activePackIDs.insert(firstPack.id)
        }
        _appState = StateObject(wrappedValue: state)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
        }
    }
}
