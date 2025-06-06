//
//  MockOrderManager.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import Foundation
import Networking
@testable import FloraList

final class MockOrderManager: OrderManager {

    private var mockOrders: [Order] = []
    private var mockCustomers: [Customer] = []

    override var orders: [Order] {
        return mockOrders
    }

    override var customers: [Customer] {
        return mockCustomers
    }

    func setMockOrders(_ orders: [Order]) {
        mockOrders = orders
    }

    func setMockCustomers(_ customers: [Customer]) {
        mockCustomers = customers
    }

    static func withTestData() -> MockOrderManager {
        let manager = MockOrderManager(notificationManager: NotificationManager())

        let orders = [
            Order(id: 1, description: "Roses Bouquet", price: 45.99, customerID: 143, imageURL: "", status: .new),
            Order(id: 2, description: "Lilies Arrangement", price: 62.50, customerID: 223, imageURL: "", status: .pending),
            Order(id: 3, description: "Sunflowers", price: 38.75, customerID: 601, imageURL: "", status: .delivered),
            Order(id: 4, description: "Tulip Collection", price: 55.00, customerID: 789, imageURL: "", status: .new)
        ]

        let customers = [
            Customer(id: 143, name: "Cristina", latitude: 46.7712, longitude: 23.6236),
            Customer(id: 223, name: "Maria", latitude: 46.7650, longitude: 23.6200),
            Customer(id: 601, name: "Mihai", latitude: 46.7800, longitude: 23.6400),
            Customer(id: 789, name: "Andrei", latitude: 46.7600, longitude: 23.6100)
        ]

        manager.setMockOrders(orders)
        manager.setMockCustomers(customers)

        return manager
    }

    static func empty() -> MockOrderManager {
        return MockOrderManager(notificationManager: NotificationManager())
    }
} 
