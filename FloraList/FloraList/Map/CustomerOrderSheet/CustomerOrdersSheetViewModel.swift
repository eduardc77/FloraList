//
//  CustomerOrdersSheetViewModel.swift
//  FloraList
//
//  Created by User on 6/8/25.
//

import SwiftUI
import Networking

@MainActor
@Observable
class CustomerOrdersSheetViewModel {
    private let orderManager: OrderManager
    private let deepLinkManager: DeepLinkManager
    private let selectedTab: Binding<AppTab>
    private let dismiss: () -> Void
    private let routeManager: RouteManager

    let customer: Customer

    var customerOrders: [Order] {
        orderManager.orders.filter { $0.customerID == customer.id }
    }

    var ordersCount: Int {
        customerOrders.count
    }

    var hasOrders: Bool {
        !customerOrders.isEmpty
    }

    init(
        customer: Customer,
        orderManager: OrderManager,
        deepLinkManager: DeepLinkManager,
        selectedTab: Binding<AppTab>,
        dismiss: @escaping () -> Void,
        routeManager: RouteManager
    ) {
        self.customer = customer
        self.orderManager = orderManager
        self.deepLinkManager = deepLinkManager
        self.selectedTab = selectedTab
        self.dismiss = dismiss
        self.routeManager = routeManager
    }

    func dismissSheet() {
        dismiss()
    }

    func navigateToOrder(_ order: Order) async {
        guard let url = URL(string: "floralist://orders/\(order.id)") else {
            print("Failed to create deep link URL for order \(order.id)")
            return
        }

        // Switch to Orders tab first, then dismiss and navigate
        selectedTab.wrappedValue = .orders
        dismiss()

        // Handle the deep link - SwiftUI will coordinate the timing
        do {
            try await deepLinkManager.handle(url)
        } catch {
            print("Failed to navigate to order \(order.id): \(error)")
        }
    }

    // MARK: - Route Management

    var isRouteShown: Bool {
        routeManager.isRouteShown(for: customer)
    }
    
    var currentRouteTime: String? {
        // Only show route time when route is actively displayed
        guard isRouteShown, let route = routeManager.currentRoute else { return nil }
        return RouteManager.formatTime(route.expectedTravelTime)
    }
    


    func showRoute() async {
        await routeManager.showRoute(to: customer)
    }

    func clearRoute() {
        routeManager.clearRoute()
    }
}
