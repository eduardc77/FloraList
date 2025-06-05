//
//  OrderServiceTests.swift
//  Networking
//
//  Created by User on 6/5/25.
//

import Testing
@testable import Networking

@Suite("REST Order Service")
struct OrderServiceTests {

    @Test("REST service fetches data successfully")
    func restServiceFetchesDataSuccessfully() async throws {
        let service = OrderService()

        let orders = try await service.fetchOrders()

        #expect(!orders.isEmpty)
        let hasNoGraphQLData = orders.allSatisfy { !$0.description.contains("(GraphQL)") }
        #expect(hasNoGraphQLData)
    }
}
