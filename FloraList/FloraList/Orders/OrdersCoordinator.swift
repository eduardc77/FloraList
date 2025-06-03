//
//  OrdersCoordinator.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import Networking

@Observable
final class OrdersCoordinator {
    var navigationPath = NavigationPath()

    enum Route: Hashable {
        case orderDetail(Order)
    }

    func showOrderDetail(_ order: Order) {
        navigationPath.append(Route.orderDetail(order))
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }

    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

private struct OrdersCoordinatorKey: EnvironmentKey {
    static let defaultValue = OrdersCoordinator()
}

extension EnvironmentValues {
    var ordersCoordinator: OrdersCoordinator {
        get { self[OrdersCoordinatorKey.self] }
        set { self[OrdersCoordinatorKey.self] = newValue }
    }
}
