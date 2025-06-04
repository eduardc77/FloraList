//
//  DeepLinkManager.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import Networking

@Observable
final class DeepLinkManager {
    private var orderManager: OrderManager?
    private var coordinator: OrdersCoordinator?

    enum DeepLinkError: LocalizedError {
        case invalidURL
        case orderNotFound
        case invalidOrderId
        case notConfigured

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The URL is not valid"
            case .orderNotFound:
                return "Order not found"
            case .invalidOrderId:
                return "Invalid order ID"
            case .notConfigured:
                return "Deep linking is not configured properly"
            }
        }
    }

    func setup(with manager: OrderManager, coordinator: OrdersCoordinator) {
        self.orderManager = manager
        self.coordinator = coordinator
    }

    func handle(_ url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == "floralist" else {
            throw DeepLinkError.invalidURL
        }

        switch components.host {
        case "orders":
            try await handleOrders(components)
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
            coordinator.showOrderDetail(order)
        }
    }
}
