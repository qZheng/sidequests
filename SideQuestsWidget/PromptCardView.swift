//
//  PromptCardView.swift
//  SideQuestsWidget
//
//  Created by Lucas Zheng on 2025-08-02.
//

import SwiftUI

struct PromptCardView: View {
    let prompt: Prompt
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(prompt.text)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            Spacer()
            
            // Metadata at the bottom
            HStack {
                // Pack name badge
                Text(prompt.packName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                
                Spacer()
                
                // Duration
                Label("\(prompt.metadata.durationInMinutes)m", systemImage: "clock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    PromptCardView(prompt: Prompt(
        id: UUID(),
        text: "Take a 10-minute walk outside",
        metadata: PromptMetadata(
            vibe: "energetic",
            durationInMinutes: 10,
            tools: ["comfortable shoes"],
            timesOfDay: [.day],
            locationContext: .any
        ),
        packName: "Fitness Fuel"
    ))
    .padding()
} 