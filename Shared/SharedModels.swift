//
//  SharedModels.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-08-02.
//

import Foundation

// MARK: - Coding User Info Keys
extension CodingUserInfoKey {
    static let packName = CodingUserInfoKey(rawValue: "packName")!
}

// MARK: - Shared Models for Widget Access

enum TimeOfDay: String, Codable, Hashable {
    case night, sunrise, day, sunset
}

enum LocationContext: String, Codable, Hashable {
    case home, notHome, any
}

/// A collection of related prompts - shared between app and widget
struct PromptPack: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let iconName: String
    let prompts: [Prompt]
}

/// A single activity prompt - shared between app and widget
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
        // Get packName from decoder.userInfo, not from JSON
        packName = decoder.userInfo[.packName] as? String ?? "Unknown Pack"
    }
    
    // Manually implement encode to include packName
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(metadata, forKey: .metadata)
        // Note: packName is not encoded in JSON, it's passed via userInfo
    }
}

/// Metadata associated with a prompt - shared between app and widget
struct PromptMetadata: Hashable, Codable {
    let vibe: String?
    let durationInMinutes: Int
    let tools: [String]
    let timesOfDay: [TimeOfDay]
    let locationContext: LocationContext

    enum CodingKeys: String, CodingKey {
        case vibe, durationInMinutes, tools, timesOfDay, locationContext
    }

    init(vibe: String?, durationInMinutes: Int, tools: [String], timesOfDay: [TimeOfDay], locationContext: LocationContext) {
        self.vibe = vibe
        self.durationInMinutes = durationInMinutes
        self.tools = tools
        self.timesOfDay = timesOfDay
        self.locationContext = locationContext
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.vibe = try container.decodeIfPresent(String.self, forKey: .vibe)
        self.durationInMinutes = try container.decode(Int.self, forKey: .durationInMinutes)
        self.tools = try container.decode([String].self, forKey: .tools)
        self.timesOfDay = try container.decode([TimeOfDay].self, forKey: .timesOfDay)
        self.locationContext = try container.decodeIfPresent(LocationContext.self, forKey: .locationContext) ?? .any
    }
}

// MARK: - Shared Constants
enum Shared {
    static let appGroupID = "group.com.Lucas.SideQuests"
    static let latestPromptKey = "latestPrompt"
}

// MARK: - Shared Storage Helper
class SharedStorageHelper {
    static func loadLatestPrompt() -> Prompt? {
        guard let data = UserDefaults(suiteName: Shared.appGroupID)?
                .data(forKey: Shared.latestPromptKey) else { return nil }
        return try? JSONDecoder().decode(Prompt.self, from: data)
    }
} 