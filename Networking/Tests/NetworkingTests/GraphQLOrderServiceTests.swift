//
//  GraphQLOrderServiceTests.swift
//  Networking
//
//  Created by User on 6/5/25.
//

import Foundation
import Testing
@testable import Networking

@Suite("GraphQL Order Service")
struct GraphQLOrderServiceTests {

    @Test("GraphQL service fetches data successfully")
    func graphQLServiceFetchesDataSuccessfully() async throws {
        let service = GraphQLOrderService()

        let orders = try await service.fetchOrders()

        #expect(!orders.isEmpty)
        let hasGraphQLOrders = orders.contains { $0.description.contains("(GraphQL)") }
        #expect(hasGraphQLOrders)
    }
} 
