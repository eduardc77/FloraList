//
//  FloraListWidget.swift
//  FloraListWidget
//
//  Created by User on 6/12/25.
//

import WidgetKit
import SwiftUI

struct FloraListWidget: Widget {
    let kind: String = "FloraListWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FloraListWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("FloraList Orders")
        .description("Stay updated on your pending flower deliveries.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    FloraListWidget()
} timeline: {
    SimpleEntry(date: .now, totalOrders: 12, pendingOrders: 5, newOrders: 3, nextDelivery: "2:30 PM", todayRevenue: 348.50)
    SimpleEntry(date: .now, totalOrders: 8, pendingOrders: 3, newOrders: 2, nextDelivery: "4:15 PM", todayRevenue: 275.00)
}

#Preview(as: .systemMedium) {
    FloraListWidget()
} timeline: {
    SimpleEntry(date: .now, totalOrders: 12, pendingOrders: 5, newOrders: 3, nextDelivery: "2:30 PM", todayRevenue: 348.50)
    SimpleEntry(date: .now, totalOrders: 8, pendingOrders: 3, newOrders: 2, nextDelivery: "4:15 PM", todayRevenue: 275.00)
}
