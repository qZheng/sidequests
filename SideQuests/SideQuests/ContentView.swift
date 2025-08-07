//
//  ContentView.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var promptStack: [Prompt] = []

    private var isFavoritesActiveAndEmpty: Bool {
        let favoritesID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        return appState.activePackIDs == [favoritesID] && appState.favoritePromptIDs.isEmpty
    }
    
    var body: some View {
        Group {
            if let currentPrompt = promptStack.last {
                PromptView(prompt: currentPrompt, onNext: showNextPrompt, onBack: showPreviousPrompt)
                    .transition(.opacity)
            } else {
                if isFavoritesActiveAndEmpty {
                    EmptyFavoritesView()
                } else if appState.activePackIDs.isEmpty {
                    EmptyStateView()
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            if promptStack.isEmpty {
                showNextPrompt()
            }
        }
        .onChange(of: appState.activePackIDs) { newActivePacks in
            if newActivePacks.isEmpty {
                promptStack.removeAll()
            } else if promptStack.isEmpty {
                showNextPrompt()
            } else {
                // If the packs changed, get a new prompt.
                promptStack.removeAll()
                showNextPrompt()
            }
        }
        .onReceive(TimeOfDayService.shared.$current) { _ in
            showNextPrompt()
        }

    }

    private func showNextPrompt() {
        if let newPrompt = getRandomPrompt() {
            withAnimation(.easeInOut(duration: 0.3)) {
                promptStack.append(newPrompt)
            }
            // Save the latest prompt for widget access
            appState.saveLatestPrompt(newPrompt)
        } else {
            // No more prompts available
            withAnimation {
                promptStack.removeAll()
            }
        }
    }
    
    private func showPreviousPrompt() {
        if promptStack.count > 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                _ = promptStack.popLast()
            }
        }
    }

    private func getRandomPrompt() -> Prompt? {
        let favoritesID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let allPrompts: [Prompt]

        if appState.activePackIDs == [favoritesID] {
            // Favorites pack is active
            let favoritedPrompts = appState.allPacks.flatMap { $0.prompts }.filter { appState.favoritePromptIDs.contains($0.id) }
            allPrompts = favoritedPrompts
        } else {
            // Regular packs are active
            let activePacks = appState.allPacks.filter { appState.activePackIDs.contains($0.id) }
            allPrompts = activePacks.flatMap { $0.prompts }
        }

        guard !allPrompts.isEmpty else { return nil }
        
        // Filter by location
        var locationFilteredPrompts = allPrompts
        
        // Check if location filtering is enabled
        let useLocationFiltering = UserDefaults.standard.bool(forKey: "useLocationFiltering")
        
        if useLocationFiltering {
            if let isAtHome = appState.isAtHome {
                locationFilteredPrompts = allPrompts.filter { prompt in
                    switch prompt.metadata.locationContext {
                    case .any:
                        return true
                    case .home:
                        return isAtHome
                    case .notHome:
                        return !isAtHome
                    }
                }
            } else {
                // If location is unknown, only show prompts that can be done anywhere
                locationFilteredPrompts = allPrompts.filter { $0.metadata.locationContext == .any }
            }
        }
        // If location filtering is disabled, use all prompts

        // Filter by time of day
        var timeFilteredPrompts = locationFilteredPrompts
        
        // Only apply if the user has "Filter by time of day" enabled
        if UserDefaults.standard.bool(forKey: "filterByTimeOfDay") {
            let tod = TimeOfDayService.shared.current
            timeFilteredPrompts = locationFilteredPrompts.filter {
                $0.metadata.timesOfDay.contains(tod)
            }
        }

        // Avoid showing the same prompt twice in a row if possible
        let recentPromptID = promptStack.last?.id
        var potentialPrompts = timeFilteredPrompts.filter { $0.id != recentPromptID }
        if potentialPrompts.isEmpty {
            potentialPrompts = timeFilteredPrompts // Or handle case where all prompts have been shown
        }

        let newPrompt = potentialPrompts.randomElement()
        
        if let newPrompt = newPrompt {
            appState.promptHistory.append(newPrompt.id)
        }
        return newPrompt
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("No Favorites Yet")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("Tap the heart on a prompt card to add it to your favorites.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, minHeight: 350)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .foregroundColor(.secondary.opacity(0.5))
            )
            .padding(.horizontal)
            Spacer()
            Spacer()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("No prompt packs selected")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("Go to the 'Packs' tab to choose some.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 350)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .foregroundColor(.secondary.opacity(0.5))
            )
            .padding(.horizontal)
            Spacer()
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyState = AppState()
        emptyState.activePackIDs.removeAll()
        
        return Group {
            ContentView()
                .environmentObject(AppState.previewState())
                .previewDisplayName("With Prompts")
            
            ContentView()
                .environmentObject(emptyState)
                .previewDisplayName("Empty State")
        }
    }
}
