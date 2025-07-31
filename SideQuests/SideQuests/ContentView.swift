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

    var body: some View {
        Group {
            if appState.activePackIDs.isEmpty {
                EmptyStateView()
            } else if let currentPrompt = promptStack.last {
                PromptView(prompt: currentPrompt, onNext: showNextPrompt, onBack: showPreviousPrompt)
                    .transition(.opacity)
            } else {
                ProgressView()
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
            }
        }
    }

    private func showNextPrompt() {
        if let newPrompt = getRandomPrompt() {
            withAnimation(.easeInOut(duration: 0.3)) {
                promptStack.append(newPrompt)
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
        let activePacks = appState.allPacks.filter { appState.activePackIDs.contains($0.id) }
        guard !activePacks.isEmpty else { return nil }
        
        let allPrompts = activePacks.flatMap { $0.prompts }
        let newPrompt = allPrompts.randomElement()
        
        if let newPrompt = newPrompt {
            appState.promptHistory.append(newPrompt.id)
        }
        return newPrompt
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
