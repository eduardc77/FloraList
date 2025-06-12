//
//  WidgetEntry.swift
//  FloraListWidget
//
//  Created by User on 6/12/25.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalOrders: Int
    let pendingOrders: Int
    let newOrders: Int
    let nextDelivery: String
    let todayRevenue: Double
}
