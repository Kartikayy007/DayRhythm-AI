//
//  DayRhythmWidgetLiveActivity.swift
//  DayRhythmWidget
//
//  Created by kartikay on 02/11/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DayRhythmWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        
        var emoji: String
    }

    
    var name: String
}

struct DayRhythmWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DayRhythmWidgetAttributes.self) { context in
            
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                
                
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "dayrhythm://open"))
            .keylineTint(Color.red)
        }
    }
}

extension DayRhythmWidgetAttributes {
    fileprivate static var preview: DayRhythmWidgetAttributes {
        DayRhythmWidgetAttributes(name: "World")
    }
}

extension DayRhythmWidgetAttributes.ContentState {
    fileprivate static var smiley: DayRhythmWidgetAttributes.ContentState {
        DayRhythmWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DayRhythmWidgetAttributes.ContentState {
         DayRhythmWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DayRhythmWidgetAttributes.preview) {
   DayRhythmWidgetLiveActivity()
} contentStates: {
    DayRhythmWidgetAttributes.ContentState.smiley
    DayRhythmWidgetAttributes.ContentState.starEyes
}
