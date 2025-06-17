//
//  OrderManager.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import Foundation
import FloraListNetwork
import FloraListDomain

@Observable
class OrderManager {
    private var orderService: OrderServiceProtocol
    private(set) var networkingType: NetworkingType
    private let analyticsManager = AnalyticsManager.shared
    private let notificationManager: NotificationManager

    private(set) var orders: [Order] = []
    private(set) var customers: [Customer] = []
    var isLoading = false
    var error: Error?

    // Default to GraphQL, but can be switched to REST
    init(networkingType: NetworkingType = .graphQL, notificationManager: NotificationManager) {
        print("OrderManager using: \(networkingType)")
        self.networkingType = networkingType
        self.orderService = ServiceFactory.createOrderService(type: networkingType)
        self.notificationManager = notificationManager
    }

    @MainActor
    func fetchData() async {
        isLoading = true
        error = nil

        do {
            async let ordersTask = orderService.fetchOrders()
            async let customersTask = orderService.fetchCustomers()

            orders = try await ordersTask
            customers = try await customersTask
        } catch {
            self.error = error
        }

        isLoading = false
    }

    @MainActor
    func updateOrderStatus(_ order: Order, status: OrderStatus) async throws {
        let oldStatus = order.status
        
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index].status = status
        }

        // In a real app, we would make an API call here
        // For MVP, we'll just simulate a delay
        try await Task.sleep(for: .seconds(0.5))
        
        // Track status update if it actually changed
        if oldStatus != status {
            analyticsManager.trackOrderStatusUpdate(
                orderId: order.id,
                oldStatus: oldStatus.displayName,
                newStatus: status.displayName
            )
        }

        // Only notify if order status changed and notifications are allowed
        if oldStatus != status && notificationManager.isPermissionGranted {
            print("Status changed from \(oldStatus) to \(status)")
            do {
                try await notificationManager.scheduleOrderStatusNotification(
                    orderId: order.id,
                    description: order.description,
                    status: status.displayName.lowercased()
                )
            } catch {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func customer(for order: Order) -> Customer? {
        customers.first { $0.id == order.customerID }
    }

    func findOrder(by id: Int) -> Order? {
        orders.first { $0.id == id }
    }
    
    @MainActor
    func switchToNetworkingType(_ type: NetworkingType) async {
        guard type != networkingType else { return }
        
        networkingType = type
        orderService = ServiceFactory.createOrderService(type: type)

        await fetchData()
    }
}
