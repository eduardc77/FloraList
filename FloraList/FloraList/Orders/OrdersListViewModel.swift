//
//  OrdersListViewModel.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import Observation
import Networking

@Observable
final class OrdersListViewModel {
    var orders: [Order] = []
    var customers: [Customer] = []
    var isLoading = false
    var errorMessage: String?

    private let orderService = OrderService()

    init() {}

    @MainActor
    func loadOrders() async {
        guard orders.isEmpty else { return }
        await fetchData()
    }

    @MainActor
    func refresh() async {
        await fetchData()
    }

    @MainActor
    private func fetchData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let ordersTask = orderService.fetchOrders()
            async let customersTask = orderService.fetchCustomers()

            orders = try await ordersTask
            customers = try await customersTask
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func customer(for order: Order) -> Customer? {
        customers.first { $0.id == order.customerID }
    }
}
