//
//  WidgetTimelineProvider.swift
//  FloraListWidget
//
//  Created by User on 6/12/25.
//

import WidgetKit
import FloraListNetwork
import FloraListDomain

struct Provider: TimelineProvider {
    private let orderService: OrderServiceProtocol
    
    init() {
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
