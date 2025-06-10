//
//  DeepLinkManager.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import Networking

@Observable
class DeepLinkManager {
    private var orderManager: OrderManager?
    private var coordinator: OrdersCoordinator?
    private var mapCoordinator: CustomerMapCoordinator?
    private var selectedTab: Binding<AppTab>?

    enum DeepLinkError: LocalizedError {
        case invalidURL
        case orderNotFound
        case customerNotFound
        case invalidOrderId
        case invalidCustomerId
        case notConfigured

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The URL is not valid"
            case .orderNotFound:
                return "Order not found"
            case .customerNotFound:
                return "Customer not found"
            case .invalidOrderId:
                return "Invalid order ID"
            case .invalidCustomerId:
                return "Invalid customer ID"
            case .notConfigured:
                return "Deep linking is not configured properly"
            }
        }
    }

    func setup(
        with manager: OrderManager,
        coordinator: OrdersCoordinator,
        mapCoordinator: CustomerMapCoordinator,
        selectedTab: Binding<AppTab>? = nil
    ) {
        self.orderManager = manager
        self.coordinator = coordinator
        self.mapCoordinator = mapCoordinator
        self.selectedTab = selectedTab
    }

    func handle(_ url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == "floralist" else {
            throw DeepLinkError.invalidURL
        }

        switch components.host {
        case "orders":
            try await handleOrders(components)
        case "map":
            try await handleMap(components)
        default:
            throw DeepLinkError.invalidURL
        }
    }

    private func handleOrders(_ components: URLComponents) async throws {
        guard let orderManager = orderManager,
              let coordinator = coordinator else {
            throw DeepLinkError.notConfigured
        }

        guard let orderIdString = components.path.split(separator: "/").last,
              let orderId = Int(orderIdString) else {
            throw DeepLinkError.invalidOrderId
        }

        guard let order = orderManager.findOrder(by: orderId) else {
            throw DeepLinkError.orderNotFound
        }

        await MainActor.run {
            coordinator.showOrderDetailFromDeepLink(order)
        }
    }

    private func handleMap(_ components: URLComponents) async throws {
        guard let orderManager = orderManager,
              let mapCoordinator = mapCoordinator,
              let selectedTab = selectedTab else {
            throw DeepLinkError.notConfigured
        }

        let pathComponents = components.path.split(separator: "/")
        
        // Handle: floralist://map/customer/123
        if pathComponents.count >= 2 && pathComponents[0] == "customer" {
            guard let customerIdString = pathComponents[1].split(separator: "/").first,
                  let customerId = Int(customerIdString) else {
                throw DeepLinkError.invalidCustomerId
            }
            
            guard let customer = orderManager.customers.first(where: { $0.id == customerId }) else {
                throw DeepLinkError.customerNotFound
            }
            
            await MainActor.run {
                // Switch to map tab first
                selectedTab.wrappedValue = .map
            }
            
            // Wait for the tab switch to complete before presenting sheet
            try await Task.sleep(for: .milliseconds(100))
            
            await MainActor.run {
                mapCoordinator.showCustomer(customer)
            }
        } else {
            // Handle: floralist://map (just switch to map tab)
            await MainActor.run {
                selectedTab.wrappedValue = .map
            }
        }
    }
}
