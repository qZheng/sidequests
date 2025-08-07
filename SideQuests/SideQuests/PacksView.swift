//
//  PacksView.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

struct PacksView: View {
    @EnvironmentObject var appState: AppState

    private var favoritesPack: PromptPack {
        let favoritePrompts = appState.allPacks.flatMap { $0.prompts }.filter { appState.favoritePromptIDs.contains($0.id) }
        return PromptPack(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, name: "Favorites", iconName: "heart.fill", prompts: favoritePrompts)
    }


    
    @State private var sortedPacks: [PromptPack] = []

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    
                    // Manually place the Favorites pack first
                    PackCard(pack: favoritesPack, isActive: appState.activePackIDs.contains(favoritesPack.id)) {
                        togglePack(favoritesPack)
                    }
                    
                    // Then the rest of the packs
                    ForEach(sortedPacks) { pack in
                        if pack.id != favoritesPack.id { // Ensure we don't duplicate it
                            PackCard(pack: pack, isActive: appState.activePackIDs.contains(pack.id)) {
                                togglePack(pack)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Quest Packs")
            .onAppear(perform: sortPacks)
        }
    }
    
    private func togglePack(_ pack: PromptPack) {
        let favoritesID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        
        if pack.id == favoritesID {
            // If favorites pack is tapped
            if appState.activePackIDs.contains(favoritesID) {
                // It's currently active, so deactivate it and restore previous selection
                appState.activePackIDs = appState.lastActivePackIDs
            } else {
                // It's not active, so activate it and save current selection
                appState.lastActivePackIDs = appState.activePackIDs
                appState.activePackIDs = [favoritesID]
            }
        } else {
            // If any other pack is tapped
            if appState.activePackIDs.contains(pack.id) {
                appState.activePackIDs.remove(pack.id)
            } else {
                appState.activePackIDs.insert(pack.id)
            }
            // If favorites was active, it should be deactivated now.
            appState.activePackIDs.remove(favoritesID)
        }
    }

    private func sortPacks() {
        self.sortedPacks = appState.allPacks.sorted { (pack1, pack2) -> Bool in
            let isPack1Active = appState.activePackIDs.contains(pack1.id)
            let isPack2Active = appState.activePackIDs.contains(pack2.id)

            if isPack1Active && !isPack2Active {
                return true
            } else if !isPack1Active && isPack2Active {
                return false
            }

            return pack1.name < pack2.name
        }
    }
}

struct PackCard: View {
    let pack: PromptPack
    let isActive: Bool
    let onTap: () -> Void

    private var accentColor: Color {
        if pack.name == "Favorites" {
            return .red
        }
        return .orange
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: pack.iconName)
                    .font(.title2)
                    .foregroundColor(accentColor)
                
                Text(pack.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isActive ? accentColor : .primary)
                    .multilineTextAlignment(.center)
                
                Text("\(pack.prompts.count) prompts")
                    .font(.caption2)
                    .foregroundColor(isActive ? accentColor.opacity(0.8) : .secondary)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}


struct PacksView_Previews: PreviewProvider {
    static var previews: some View {
        PacksView()
            .environmentObject(AppState.previewState())
    }
}
