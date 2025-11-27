//
//  ScheduleBSUIRWidgetLiveActivity.swift
//  ScheduleBSUIRWidget
//
//  Created by user on 30.10.25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ScheduleBSUIRWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ScheduleBSUIRWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScheduleBSUIRWidgetAttributes.self) { context in
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
                Text("Leading")
            } compactTrailing: {
                Text("Trailing")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ScheduleBSUIRWidgetAttributes {
    fileprivate static var preview: ScheduleBSUIRWidgetAttributes {
        ScheduleBSUIRWidgetAttributes(name: "World")
    }
}

extension ScheduleBSUIRWidgetAttributes.ContentState {
    fileprivate static var smiley: ScheduleBSUIRWidgetAttributes.ContentState {
        ScheduleBSUIRWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ScheduleBSUIRWidgetAttributes.ContentState {
         ScheduleBSUIRWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ScheduleBSUIRWidgetAttributes.preview) {
   ScheduleBSUIRWidgetLiveActivity()
} contentStates: {
    ScheduleBSUIRWidgetAttributes.ContentState.smiley
    ScheduleBSUIRWidgetAttributes.ContentState.starEyes
}
