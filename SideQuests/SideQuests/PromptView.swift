//
//  PromptView.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

struct PromptView: View {
    @EnvironmentObject var appState: AppState
    let prompt: Prompt
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var isFavorite: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            promptCard
                .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .task {
            isFavorite = appState.favoritePromptIDs.contains(prompt.id)
        }
        .contentShape(Rectangle()) // Make the whole area tappable
        .gesture(
            TapGesture().onEnded {
                onNext()
            }
        )
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    // Swipe right
                    if value.translation.width > 0 {
                        onBack()
                    }
                }
        )
    }

    private var promptCard: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .center, spacing: 16) {
                Text(prompt.text)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .padding(40)

                Spacer() // Pushes the metadata to the bottom
            }
            .frame(maxWidth: .infinity, minHeight: 350)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 5)
            .overlay(
                // Action buttons in the bottom right
                actionButtons
                    .padding(),
                alignment: .bottomTrailing
            )
            
            // Metadata in the bottom left
            metadataView
                .padding()
        }
    }

    private var metadataView: some View {
        VStack(alignment: .leading) {
            Text(prompt.packName)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            
            HStack(spacing: 16) {
                Label("\(prompt.metadata.durationInMinutes) min", systemImage: "clock")
                if !prompt.metadata.tools.isEmpty {
                    Label(prompt.metadata.tools.joined(separator: ", "), systemImage: "wrench.and.screwdriver")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(isFavorite ? .red : .secondary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .highPriorityGesture(TapGesture().onEnded { _ in toggleFavorite() })

            Button(action: {
                // TODO: Mark as completed
            }) {
                Image(systemName: "checkmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            .highPriorityGesture(TapGesture().onEnded { _ in /* Mark as completed */ })
        }
    }

    private func toggleFavorite() {
        isFavorite.toggle()
        if isFavorite {
            appState.favoritePromptIDs.insert(prompt.id)
        } else {
            appState.favoritePromptIDs.remove(prompt.id)
        }
    }
}

struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView(
            prompt: Prompt(
                id: UUID(),
                text: "Look out a window and find something you've never noticed before.",
                metadata: .init(vibe: "curious", durationInMinutes: 5, tools: ["eyes"], timesOfDay: [.day]),
                packName: "Mindful Moments"
            ),
            onNext: {},
            onBack: {}
        )
        .environmentObject(AppState.previewState())
    }
}
