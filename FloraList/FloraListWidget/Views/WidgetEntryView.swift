//
//  WidgetEntryView.swift
//  FloraListWidget
//
//  Created by User on 6/12/25.
//

import SwiftUI
import WidgetKit

struct FloraListWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}
