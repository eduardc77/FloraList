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

    /// Normal navigation - appends to current stack
    func showOrderDetail(_ order: Order) {
        navigationPath.append(Route.orderDetail(order))
    }
    
    /// Deep link navigation - replaces stack with just this detail
    func showOrderDetailFromDeepLink(_ order: Order) {
        navigationPath = NavigationPath()
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
