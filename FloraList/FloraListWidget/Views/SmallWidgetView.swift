//
//  SmallWidgetView.swift
//  FloraListWidget
//
//  Created by User on 6/12/25.
//

import SwiftUI

struct SmallWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            ordersSection
            Spacer()
            nextDeliverySection
            Spacer()
        }
        .padding(4)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "leaf.fill")
                .foregroundStyle(.green)
                .font(.title2)
            Text("FloraList")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.bottom, 10)
    }

    private var ordersSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            totalOrdersView
            statusLabelsView
        }
    }

    private var totalOrdersView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(entry.totalOrders)")
                .font(.title)
                .fontWeight(.bold)
            Text("Total Orders")
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

    private var nextDeliverySection: some View {
        Text("Next: \(entry.nextDelivery)")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
    }
}
