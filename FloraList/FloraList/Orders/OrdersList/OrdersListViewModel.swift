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
    private let orderManager: OrderManager

    var searchText = ""
    var selectedStatus: OrderStatus?

    enum SortOption: String, CaseIterable {
        case priceHighToLow = "Price: High to Low"
        case priceLowToHigh = "Price: Low to High"
        case status = "Status"
    }

    var selectedSortOption: SortOption?

    var isLoading: Bool { orderManager.isLoading }
    var errorMessage: String? { orderManager.error?.localizedDescription }

    var filteredAndSortedOrders: [Order] {
        orderManager.orders
            .search(with: searchText)
            .filtered(by: selectedStatus)
            .sorted(by: selectedSortOption)
    }

    init(orderManager: OrderManager) {
        self.orderManager = orderManager
    }

    // MARK: - Methods

    func clearFilters() {
        searchText = ""
        selectedStatus = nil
        selectedSortOption = nil
    }

    func customer(for order: Order) -> Customer? {
        orderManager.customer(for: order)
    }

    @MainActor
    func loadOrders() async {
        guard orderManager.orders.isEmpty else { return }
        await orderManager.fetchData()
    }

    @MainActor
    func refresh() async {
        await orderManager.fetchData()
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
