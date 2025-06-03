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

    var searchText = ""
    var selectedStatus: OrderStatus?

    enum SortOption: String, CaseIterable {
        case priceHighToLow = "Price: High to Low"
        case priceLowToHigh = "Price: Low to High"
        case status = "Status"
    }

    var selectedSortOption: SortOption?

    private let orderService = OrderService()

    var filteredAndSortedOrders: [Order] {
        orders
            .search(with: searchText)
            .filtered(by: selectedStatus)
            .sorted(by: selectedSortOption)
    }

    // MARK: - Methods

    func clearFilters() {
        searchText = ""
        selectedStatus = nil
        selectedSortOption = nil
    }

    func customer(for order: Order) -> Customer? {
        customers.first { $0.id == order.customerID }
    }

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
}

// MARK: - Search, Filter and Sort

private extension Array where Element == Order {
    func search(with text: String) -> [Order] {
        guard !text.isEmpty else { return self }
        return filter { order in
            order.description.localizedCaseInsensitiveContains(text)
        }
    }

    func filtered(by status: OrderStatus?) -> [Order] {
        guard let status else { return self }
        return filter { $0.status == status }
    }

    func sorted(by option: OrdersListViewModel.SortOption?) -> [Order] {
        guard let option else { return self }

        switch option {
        case .priceHighToLow:
            return sorted { $0.price > $1.price }
        case .priceLowToHigh:
            return sorted { $0.price < $1.price }
        case .status:
            return sorted { $0.status.rawValue < $1.status.rawValue }
        }
    }
}
