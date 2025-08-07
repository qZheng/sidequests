//
//  SideQuestsWidgetLiveActivity.swift
//  SideQuestsWidget
//
//  Created by Lucas Zheng on 2025-08-02.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SideQuestsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SideQuestsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SideQuestsWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SideQuestsWidgetAttributes {
    fileprivate static var preview: SideQuestsWidgetAttributes {
        SideQuestsWidgetAttributes(name: "World")
    }
}

extension SideQuestsWidgetAttributes.ContentState {
    fileprivate static var smiley: SideQuestsWidgetAttributes.ContentState {
        SideQuestsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SideQuestsWidgetAttributes.ContentState {
         SideQuestsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SideQuestsWidgetAttributes.preview) {
   SideQuestsWidgetLiveActivity()
} contentStates: {
    SideQuestsWidgetAttributes.ContentState.smiley
    SideQuestsWidgetAttributes.ContentState.starEyes
}
