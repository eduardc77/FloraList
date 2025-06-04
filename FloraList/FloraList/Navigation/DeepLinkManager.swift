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
    private let orderService = OrderService()
    private var ordersCoordinator: OrdersCoordinator?

    enum DeepLinkError: LocalizedError {
        case invalidURL
        case orderNotFound
        case invalidOrderId

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The URL is not valid"
            case .orderNotFound:
                return "Order not found"
            case .invalidOrderId:
                return "Invalid order ID"
            }
        }
    }

    func setup(with coordinator: OrdersCoordinator) {
        self.ordersCoordinator = coordinator
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
        guard let orderIdString = components.path.split(separator: "/").last,
              let orderId = Int(orderIdString) else {
            throw DeepLinkError.invalidOrderId
        }

        let orders = try await orderService.fetchOrders()
        guard let order = orders.first(where: { $0.id == orderId }) else {
            throw DeepLinkError.orderNotFound
        }

        await MainActor.run {
            ordersCoordinator?.showOrderDetail(order)
        }
    }
}
