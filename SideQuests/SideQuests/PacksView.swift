//
//  PacksView.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import SwiftUI

struct PacksView: View {
    @EnvironmentObject var appState: AppState
    @State private var packs: [PromptPack] = []

    var body: some View {
        NavigationView {
            ScrollView {
                if packs.isEmpty {
                    Text("No Quest Packs Found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(packs) { pack in
                            PackCard(pack: pack, isActive: appState.activePackIDs.contains(pack.id)) {
                                togglePack(pack)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Quest Packs")
            .onAppear(perform: sortPacks)
        }
    }
    
    private func togglePack(_ pack: PromptPack) {
        if appState.activePackIDs.contains(pack.id) {
            appState.activePackIDs.remove(pack.id)
        } else {
            appState.activePackIDs.insert(pack.id)
        }
        // Force the view to re-evaluate the active state for color changes
        self.packs = self.packs
    }

    private func sortPacks() {
        self.packs = appState.allPacks.sorted { (pack1, pack2) -> Bool in
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
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: pack.iconName)
                    .font(.title2)
                    .foregroundColor(isActive ? .white : .orange)
                
                Text(pack.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isActive ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                Text("\(pack.prompts.count) prompts")
                    .font(.caption2)
                    .foregroundColor(isActive ? .white.opacity(0.8) : .secondary)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isActive ? Color.orange : Color(.secondarySystemBackground))
            .cornerRadius(12)
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
