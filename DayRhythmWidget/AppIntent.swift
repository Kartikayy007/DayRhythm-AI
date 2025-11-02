//
//  AppIntent.swift
//  DayRhythmWidget
//
//  Created by kartikay on 02/11/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
