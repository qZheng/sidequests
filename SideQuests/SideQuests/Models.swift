//
//  Models.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
//

import Foundation

/// The time of day for a prompt.
enum TimeOfDay: String, Codable, Hashable {
    case night, sunrise, day, sunset
}

/// A single activity prompt.
struct Prompt: Identifiable, Hashable, Codable {
    let id: UUID
    let text: String
    let metadata: PromptMetadata
    let packName: String
}

/// Metadata associated with a prompt.
struct PromptMetadata: Hashable, Codable {
    let vibe: String?
    let durationInMinutes: Int
    let tools: [String]
    let timesOfDay: [TimeOfDay]
}

/// A collection of related prompts.
struct PromptPack: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let iconName: String
    var prompts: [Prompt]
}
