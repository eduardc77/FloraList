//
//  OrderServiceTests.swift
//  FloraListNetwork
//
//  Created by User on 6/5/25.
//

import Testing
@testable import FloraListNetwork
import Foundation

@Suite(.serialized)
struct OrderServiceTests {

    @Test("fetchOrders success")
    func testFetchOrders() async throws {
        
        // Use centralized test data
        let mockOrders = TestData.orders
        
        let mockData = try JSONEncoder().encode(mockOrders)

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "http://demo7677712.mockable.io/orders")
            #expect(request.httpMethod == "GET")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    mockData)
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let service = OrderService(session: session)
        let result = try await service.fetchOrders()
        
        #expect(result.count == mockOrders.count)
        #expect(result[0].description == "Roses Bouquet")
        #expect(result[0].price == 45.99)
        #expect(result[0].customerID == 143)
        #expect(result[0].status == .new)
        #expect(result[1].description == "Lilies Arrangement")
        #expect(result[1].customerID == 223)
    }

    @Test("fetchCustomers success")
    func testFetchCustomers() async throws {
        
        // Use centralized test data
        let mockCustomers = TestData.customers
        
        let mockData = try JSONEncoder().encode(mockCustomers)

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "http://demo7677712.mockable.io/customers")
            #expect(request.httpMethod == "GET")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    mockData)
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let service = OrderService(session: session)
        let result = try await service.fetchCustomers()
        
        #expect(result.count == mockCustomers.count)
        #expect(result[0].name == "Cristina")
        #expect(result[0].latitude == 46.7712)
        #expect(result[0].longitude == 23.6236)
        #expect(result[1].name == "Maria")
        #expect(result[1].longitude == 23.6200)
    }

    @Test("fetchOrders server error")
    func testFetchOrdersError() async throws {
        
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!,
                    Data())
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let service = OrderService(session: session)
        
        await #expect(throws: NetworkError.self) {
            try await service.fetchOrders()
        }
    }
}
