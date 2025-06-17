//
//  GraphQLOrderServiceTests.swift
//  FloraListNetwork
//
//  Created by User on 6/5/25.
//

import Foundation
import Testing
@testable import FloraListNetwork

@Suite(.serialized)
struct GraphQLOrderServiceTests {

    @Test func testFetchOrdersSuccess() async throws {
        
        // Use centralized test data
        let testOrders = TestData.orders
        
        let graphQLOrders = testOrders.map { order in
            """
              {
                "id": \(order.id),
                "description": "\(order.description)",
                "price": \(order.price),
                "customerID": \(order.customerID),
                "imageURL": "\(order.imageURL)",
                "status": "\(order.status.rawValue)"
              }
            """
        }.joined(separator: ",")
        
        let mockResponse = """
        {
          "data": {
            "orders": [\(graphQLOrders)]
          }
        }
        """
        
        GraphQLMockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://ba8312ca-45f2-4ed3-86b6-047cf8926e92.mock.pstmn.io/graphql")
            #expect(request.httpMethod == "POST")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    mockResponse.data(using: .utf8)!)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [GraphQLMockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let service = GraphQLOrderService(session: session)
        let orders = try await service.fetchOrders()
        
        #expect(orders.count == testOrders.count)
        #expect(orders[0].description == "Roses Bouquet")
        #expect(orders[0].price == 45.99)
        #expect(orders[0].customerID == 143)
        #expect(orders[0].status == .new)
        #expect(orders[1].description == "Lilies Arrangement")
        #expect(orders[1].price == 62.50)
        #expect(orders[1].customerID == 223)
        #expect(orders[1].status == .pending)
    }

    @Test func testFetchCustomersSuccess() async throws {
        
        // Use centralized test data
        let testCustomers = TestData.customers
        
        let graphQLCustomers = testCustomers.map { customer in
            """
              {
                "id": \(customer.id),
                "name": "\(customer.name)",
                "latitude": \(customer.latitude),
                "longitude": \(customer.longitude)
              }
            """
        }.joined(separator: ",")
        
        let mockResponse = """
        {
          "data": {
            "customers": [\(graphQLCustomers)]
          }
        }
        """
        
        GraphQLMockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://ba8312ca-45f2-4ed3-86b6-047cf8926e92.mock.pstmn.io/graphql")
            #expect(request.httpMethod == "POST")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    mockResponse.data(using: .utf8)!)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [GraphQLMockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let service = GraphQLOrderService(session: session)
        let customers = try await service.fetchCustomers()
        
        #expect(customers.count == testCustomers.count)
        #expect(customers[0].name == "Cristina")
        #expect(customers[0].latitude == 46.7712)
        #expect(customers[0].longitude == 23.6236)
        #expect(customers[1].name == "Maria")
        #expect(customers[1].latitude == 46.7650)
        #expect(customers[1].longitude == 23.6200)
    }

    @Test func testNetworkError() async throws {
        
        GraphQLMockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!,
                    Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [GraphQLMockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let service = GraphQLOrderService(session: session)
        
        await #expect(throws: URLError.self) {
            try await service.fetchOrders()
        }
    }
} 
