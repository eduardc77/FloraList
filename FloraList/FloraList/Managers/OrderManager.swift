//
//  OrderManager.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import Foundation
import Networking

@Observable
class OrderManager {
    private let orderService: OrderServiceProtocol

    private(set) var orders: [Order] = []
    private(set) var customers: [Customer] = []
    var isLoading = false
    var error: Error?

    // Default to GraphQL, but can be switched to REST
    init(networkingType: NetworkingType = .graphQL) {
        print("OrderManager using: \(networkingType)")
        self.orderService = ServiceFactory.createOrderService(type: networkingType)
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
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index].status = status
        }

        // In a real app, we would make an API call here
        // For MVP, we'll just simulate a delay
        try await Task.sleep(for: .seconds(0.5))
    }

    func customer(for order: Order) -> Customer? {
        customers.first { $0.id == order.customerID }
    }

    func findOrder(by id: Int) -> Order? {
        orders.first { $0.id == id }
    }
}
