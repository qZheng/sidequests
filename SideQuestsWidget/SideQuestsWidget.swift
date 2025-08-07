//
//  SideQuestsWidget.swift
//  SideQuestsWidget
//
//  Created by Lucas Zheng on 2025-08-02.
//

import WidgetKit
import SwiftUI

// 1️⃣ The model that represents one widget "snapshot"
struct TaskEntry: TimelineEntry {
    let date: Date
    let prompt: Prompt?      // Reuse your app's Prompt type
}

// 2️⃣ The provider that tells WidgetKit when & what to show
struct TaskProvider: TimelineProvider {
    
    // Shown in the widget gallery and during development
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), prompt: nil)
    }
    
    // A "quick" snapshot for the widget (e.g. in the widget list)
    func getSnapshot(in context: Context,
                     completion: @escaping (TaskEntry) -> Void) {
        let entry = TaskEntry(
            date: Date(),
            prompt: SharedStorageHelper.loadLatestPrompt()  // your helper
        )
        completion(entry)
    }
    
    // The timeline of entries: here, 1 entry refreshed hourly
/*     func getTimeline(in context: Context,
                     completion: @escaping (Timeline<TaskEntry>) -> Void) {
        print("getTimeline")
        let now = Date()
        let entry = TaskEntry(
            date: now,
            prompt: SharedStorageHelper.loadLatestPrompt()
        )
        print("entry: \(entry)")
        
        // Next update: 1 hour later
        let nextUpdate = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: now
        )!
        
        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )
        completion(timeline)
    } */
    func getTimeline(in context: Context,
                 completion: @escaping (Timeline<TaskEntry>) -> Void) {
    let prompt = SharedStorageHelper.loadLatestPrompt()
    print("🕒 [Widget] timeline prompt:", prompt ?? "nil")
    let entry = TaskEntry(date: Date(), prompt: prompt)
    let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    completion(Timeline(entries: [entry], policy: .after(next)))
}

}

struct SideQuestsWidgetEntryView: View {
    let entry: TaskProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        ZStack {
            if let prompt = entry.prompt {
                // Mirror your in-app card
                PromptCardView(prompt: prompt)
                    .padding(8)
                
                if #available(iOS 17.0, *) {
                    // Place a small refresh button in the bottom-right corner
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(intent: RefreshPromptIntent()) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .opacity(0.8)
                            }
                            .buttonStyle(.plain)
                            .padding(8)
                        }
                    }
                }
            } else {
                Text("No prompt available")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

struct SideQuestsWidget: Widget {
    let kind: String = "SideQuestsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskProvider()) { entry in
            if #available(iOS 17.0, *) {
                SideQuestsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SideQuestsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("SideQuests")
        .description("Shows your latest activity prompt.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    SideQuestsWidget()
} timeline: {
    TaskEntry(date: .now, prompt: nil)
    TaskEntry(date: .now, prompt: Prompt(
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
}
