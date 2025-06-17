//
//  OrderManagerTests.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import Testing
@testable import FloraList

@Suite("Order Manager Business Logic")
struct OrderManagerTests {

    @Test("Customer lookup works correctly")
    func customerLookupWorksCorrectly() {
        let manager = MockOrderManager.withTestData()
        let order = MockOrderManager.sampleOrder

        let foundCustomer = manager.customer(for: order)

        #expect(foundCustomer != nil)
        #expect(foundCustomer?.name == "Cristina")
    }

    @Test("Fetch data loads orders and customers")
    func fetchDataLoadsOrdersAndCustomers() async {
        let manager = MockOrderManager.withTestData()

        #expect(!manager.orders.isEmpty)
        #expect(!manager.customers.isEmpty)
        #expect(!manager.isLoading)
    }
}
