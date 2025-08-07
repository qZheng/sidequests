//
//  QuestPackLoader.swift
//  SideQuestsWidget
//
//  Created by Lucas Zheng on 2025-08-02.
//

import Foundation

class QuestPackLoader {
    static func loadPacks() -> [PromptPack] {
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let questPacksURL = bundleURL.appendingPathComponent("questpacks")

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: questPacksURL, includingPropertiesForKeys: nil)
            return fileURLs.compactMap { url -> PromptPack? in
                guard url.pathExtension == "json" else { return nil }
                
                // First, decode just the pack name
                guard let partialPack = decodePartial(from: url) else { return nil }
                
                // Now, decode the full pack with the pack name in user info
                return decode(from: url, packName: partialPack.name)
            }
        } catch {
            print("Error loading quest packs directory: \(error)")
            return []
        }
    }

    private static func decode<T: Decodable>(from url: URL, packName: String? = nil) -> T? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            if let packName = packName {
                decoder.userInfo[.packName] = packName
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error decoding \(T.self) from \(url.lastPathComponent): \(error)")
            return nil
        }
    }
    
    // Helper to decode just the name for use in the full decode
    private struct PartialPromptPack: Decodable {
        let name: String
    }
    
    private static func decodePartial(from url: URL) -> PartialPromptPack? {
        decode(from: url)
    }
} 