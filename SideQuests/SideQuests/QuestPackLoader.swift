//
//  QuestPackLoader.swift
//  SideQuests
//
//  Created by Lucas Zheng on 2025-07-30.
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
                guard var pack: PromptPack = decode(from: url) else { return nil }
                
                pack.prompts = pack.prompts.map { prompt in
                    Prompt(
                        id: prompt.id,
                        text: prompt.text,
                        metadata: prompt.metadata,
                        packName: pack.name
                    )
                }
                return pack
            }
        } catch {
            print("Error loading quest packs directory: \(error)")
            return []
        }
    }

    private static func decode<T: Decodable>(from url: URL) -> T? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error decoding \(T.self) from \(url.lastPathComponent): \(error)")
            return nil
        }
    }
}
