//
//  OrderManagerTests.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import Testing
import Networking
@testable import FloraList

@Suite("Order Manager Business Logic")
struct OrderManagerTests {

    @Test("Customer lookup works correctly")
    func customerLookupWorksCorrectly() {
        let manager = MockOrderManager.withTestData()
        let order = Order(id: 1, description: "Test Order", price: 50.0, customerID: 143, imageURL: "", status: .new)

        let foundCustomer = manager.customer(for: order)

        #expect(foundCustomer != nil)
        #expect(foundCustomer?.name == "Cristina")
    }

    @Test("Fetch data loads orders and customers")
    func fetchDataLoadsOrdersAndCustomers() async {
        let manager = OrderManager(notificationManager: NotificationManager())

        await manager.fetchData()

        #expect(!manager.orders.isEmpty)
        #expect(!manager.customers.isEmpty)
        #expect(!manager.isLoading)
    }
}
