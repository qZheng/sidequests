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

    enum CodingKeys: String, CodingKey {
        case id, text, metadata
    }

    // Convenience init for creating prompts manually (e.g., in previews)
    init(id: UUID, text: String, metadata: PromptMetadata, packName: String) {
        self.id = id
        self.text = text
        self.metadata = metadata
        self.packName = packName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        metadata = try container.decode(PromptMetadata.self, forKey: .metadata)

        if let packName = decoder.userInfo[CodingUserInfoKey(rawValue: "packName")!] as? String {
            self.packName = packName
        } else {
            // Fallback for when packName is not in userInfo, e.g., when decoding a single prompt
            self.packName = "Unknown Pack"
        }
    }
    
    // Manually implement encode to exclude packName
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(metadata, forKey: .metadata)
    }
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
    let prompts: [Prompt]
}
