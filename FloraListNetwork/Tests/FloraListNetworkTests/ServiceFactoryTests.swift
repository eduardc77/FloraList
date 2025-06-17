//
//  ServiceFactoryTests.swift
//  FloraListNetwork
//
//  Created by User on 6/5/25.
//

import Testing
@testable import FloraListNetwork

@Suite("Service Factory")
struct ServiceFactoryTests {

    @Test("Service factory creates correct service types")
    func serviceFactoryCreatesCorrectServiceTypes() {
        let restService = ServiceFactory.createOrderService(type: .rest)
        let graphQLService = ServiceFactory.createOrderService(type: .graphQL)

        #expect(restService is OrderService)
        #expect(graphQLService is GraphQLOrderService)
    }
} 
