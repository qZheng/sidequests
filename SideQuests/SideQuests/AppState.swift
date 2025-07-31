//
//  AppState.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

/// Manages the global state of the application.
class AppState: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = Theme.system.rawValue
    @AppStorage("maxDurationPreference") var maxDurationPreference: Int = 15
    
    @Published var allPacks: [PromptPack] = []
    @Published var activePackIDs: Set<UUID> = []
    @Published var promptHistory: [UUID] = []
    @Published var favoritePromptIDs: Set<UUID> = []
    
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
