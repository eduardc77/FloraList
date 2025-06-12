//
//  FloraListWidget.swift
//  FloraListWidget
//
//  Created by User on 6/12/25.
//

import WidgetKit
import SwiftUI
import Networking

struct Provider: TimelineProvider {
    private let orderService: OrderServiceProtocol
    
    init() {
        // Use GraphQL service
        self.orderService = ServiceFactory.createOrderService(type: .graphQL)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            totalOrders: 12,
            pendingOrders: 5,
            newOrders: 3,
            nextDelivery: "2:30 PM",
            todayRevenue: 348.50
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(
            date: Date(),
            totalOrders: 8,
            pendingOrders: 3,
            newOrders: 2,
            nextDelivery: "1:45 PM",
            todayRevenue: 275.00
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            do {
                let orders = try await orderService.fetchOrders()
                let entry = createEntry(from: orders, date: Date())
                
                // Create timeline with single entry that updates every 15 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
                
            } catch {
                print("Widget failed to fetch data: \(error)")
                // Fallback to placeholder data
                let entry = SimpleEntry(
                    date: Date(),
                    totalOrders: 0,
                    pendingOrders: 0,
                    newOrders: 0,
                    nextDelivery: "No deliveries",
                    todayRevenue: 0.0
                )
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300))) // Retry in 5 minutes
                completion(timeline)
            }
        }
    }
    
    private func createEntry(from orders: [Order], date: Date) -> SimpleEntry {
        let totalOrders = orders.count
        let pendingOrders = orders.filter { $0.status == .pending }.count
        let newOrders = orders.filter { $0.status == .new }.count
        
        // Calculate today's revenue from delivered orders
        let todayRevenue = orders
            .filter { $0.status == .delivered }
            .reduce(0) { $0 + $1.price }

        let nextDelivery = formatNextDelivery(for: date)
        
        return SimpleEntry(
            date: date,
            totalOrders: totalOrders,
            pendingOrders: pendingOrders,
            newOrders: newOrders,
            nextDelivery: nextDelivery,
            todayRevenue: todayRevenue
        )
    }

    private func formatNextDelivery(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date.addingTimeInterval(3600)) // Next hour
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalOrders: Int
    let pendingOrders: Int
    let newOrders: Int
    let nextDelivery: String
    let todayRevenue: Double
}

struct FloraListWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        default:
            mediumWidgetView
        }
    }
    
        private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
                Text("FloraList")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.bottom, 12)
            
            // Orders section
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.totalOrders)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Total Orders")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("\(entry.newOrders)", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Label("\(entry.pendingOrders)", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            Text("Next: \(entry.nextDelivery)")
                .font(.caption)
                .foregroundStyle(.secondary)
                
            Spacer()
        }
        .padding(4)
    }
    
    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
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

            // Orders section
            HStack {
                // Orders column
                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading) {
                        Text("\(entry.totalOrders)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Total Orders")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("\(entry.newOrders) New".uppercased(), systemImage: "plus.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Label("\(entry.pendingOrders) Pending".uppercased(), systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                }
                Spacer()
                Divider()
                Spacer()

                // Revenue column
                VStack(alignment: .trailing, spacing: 4) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(entry.todayRevenue, specifier: "%.0f")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        Text("Revenue")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Next: \(entry.nextDelivery)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

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
