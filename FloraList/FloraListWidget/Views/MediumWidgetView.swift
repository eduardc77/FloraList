//
//  MediumWidgetView.swift
//  FloraListWidget
//
//  Created by User on 6/12/25.
//

import SwiftUI

struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            contentSection
            Spacer()
        }
        .padding(8)
    }
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "leaf.fill")
                .foregroundStyle(.green)
                .font(.title2)
            Text("FloraList")
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Text(formatTime(entry.date))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom)
    }
    
    private var contentSection: some View {
        HStack {
            ordersColumn
            Spacer()
            Divider()
            Spacer()
            revenueColumn
        }
    }
    
    private var ordersColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            totalOrdersView
            statusLabelsView
        }
    }
    
    private var totalOrdersView: some View {
        VStack(alignment: .leading) {
            Text("\(entry.totalOrders)")
                .font(.title)
                .fontWeight(.bold)
            Text(.totalOrders)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    private var statusLabelsView: some View {
        HStack {
            Label("\(entry.newOrders)", systemImage: "plus.circle.fill")
                .foregroundStyle(.blue)
            Label("\(entry.pendingOrders)", systemImage: "clock.fill")
                .foregroundStyle(.orange)
        }
        .font(.caption)
        .fontWeight(.medium)
    }
    
    private var revenueColumn: some View {
        VStack(alignment: .trailing, spacing: 4) {
            revenueView
            nextDeliveryView
        }
    }
    
    private var revenueView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("$\(entry.todayRevenue, specifier: "%.0f")")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.green)
            Text(.revenue)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    private var nextDeliveryView: some View {
        Text(String(localized: .revenueNextFormat(entry.nextDelivery)))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
