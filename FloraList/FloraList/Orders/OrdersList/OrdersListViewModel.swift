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
        var result = orders

        // Search
        if !searchText.isEmpty {
            result = result.filter { order in
                order.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter by status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        // Sort
        if let sortOption = selectedSortOption {
            switch sortOption {
            case .priceHighToLow:
                result.sort { $0.price > $1.price }
            case .priceLowToHigh:
                result.sort { $0.price < $1.price }
            case .status:
                result.sort { $0.status.rawValue < $1.status.rawValue }
            }
        }

        return result
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
