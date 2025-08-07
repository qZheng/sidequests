//
//  RefreshPromptIntent.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-08-02.
//

import AppIntents
import WidgetKit

@available(iOS 17.0, *)
struct RefreshPromptIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Prompt"
    static var description = IntentDescription("Fetch a new prompt and update the widget.")

    func perform() async throws -> some IntentResult {
        // 1. Generate or fetch a brand-new prompt
        let newPrompt = getRandomPrompt()   // your existing logic
        // 2. Persist it to the App Group
        guard let data = try? JSONEncoder().encode(newPrompt) else { return .result() }
        UserDefaults(suiteName: Shared.appGroupID)?
            .set(data, forKey: Shared.latestPromptKey)
        // 3. Immediately reload the widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "SideQuestsWidget")
        return .result()
    }
    
    // Helper function to generate a random prompt (similar to ContentView logic)
    private func getRandomPrompt() -> Prompt? {
        // Load all packs and get a random prompt
        let allPacks = QuestPackLoader.loadPacks()
        let allPrompts = allPacks.flatMap { $0.prompts }
        
        guard !allPrompts.isEmpty else { return nil }
        
        // For simplicity, just return a random prompt
        // In a full implementation, you'd want to replicate the filtering logic from ContentView
        return allPrompts.randomElement()
    }
} 