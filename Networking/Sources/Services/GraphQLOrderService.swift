//
//  GraphQLOrderService.swift
//  Networking
//
//  Created by User on 6/5/25.
//

import Foundation

public class GraphQLOrderService {
    public init() {}

    public func fetchOrders() async throws -> [Order] {
        print("Using GraphQL OrderService - fetching orders")

        // Simulate GraphQL query processing time
        try await Task.sleep(for: .milliseconds(200))

        let mockGraphQLResponse = """
        {
          "data": {
            "orders": [
              {
                "id": "1",
                "description": "Roses Bouquet (GraphQL)",
                "price": 45.99,
                "customerID": "143",
                "imageURL": "https://images.unsplash.com/photo-1559779080-6970e0186790?w=400",
                "status": "new"
              },
              {
                "id": "2", 
                "description": "Lilies Arrangement (GraphQL)",
                "price": 62.50,
                "customerID": "223",
                "imageURL": "https://images.unsplash.com/photo-1519064438923-de4de326dfd1?w=400",
                "status": "pending"
              },
              {
                "id": "3",
                "description": "Sunflowers (GraphQL)",
                "price": 38.75,
                "customerID": "601",
                "imageURL": "https://plus.unsplash.com/premium_photo-1676692121474-a3e3890d39f4?w=400",
                "status": "new"
              },
              {
                "id": "4",
                "description": "Tulip Collection (GraphQL)",
                "price": 55.00,
                "customerID": "789",
                "imageURL": "https://images.unsplash.com/photo-1520763185298-1b434c919102?w=400",
                "status": "pending"
              },
              {
                "id": "5",
                "description": "Orchid Elegance (GraphQL)",
                "price": 89.99,
                "customerID": "456",
                "imageURL": "https://images.unsplash.com/photo-1562133558-4a3906179c67?w=400",
                "status": "delivered"
              }
            ]
          }
        }
        """

        let orders = try parseOrdersFromGraphQLResponse(mockGraphQLResponse)
        print("GraphQL: Successfully fetched \(orders.count) orders")
        return orders
    }

    public func fetchCustomers() async throws -> [Customer] {
        print("Using GraphQL OrderService - fetching customers")

        // Simulate GraphQL query processing time
        try await Task.sleep(for: .milliseconds(150))

        let mockGraphQLResponse = """
        {
          "data": {
            "customers": [
              {
                "id": "143",
                "name": "Elena (GraphQL)",
                "latitude": 46.771677,
                "longitude": 23.601018
              },
              {
                "id": "223",
                "name": "Stefan (GraphQL)",
                "latitude": 46.757919,
                "longitude": 23.546688
              },
              {
                "id": "601",
                "name": "Diana (GraphQL)",
                "latitude": 46.562789,
                "longitude": 23.784734
              },
              {
                "id": "789",
                "name": "Radu (GraphQL)",
                "latitude": 46.790540,
                "longitude": 23.570220
              },
              {
                "id": "456",
                "name": "Ioana (GraphQL)",
                "latitude": 46.742680,
                "longitude": 23.635890
              }
            ]
          }
        }
        """

        let customers = try parseCustomersFromGraphQLResponse(mockGraphQLResponse)
        print("GraphQL: Successfully fetched \(customers.count) customers")
        return customers
    }

    // MARK: - Private Helpers

    private func parseOrdersFromGraphQLResponse(_ jsonString: String) throws -> [Order] {
        guard let data = jsonString.data(using: .utf8) else {
            throw NetworkError.decodingError(NSError(domain: "ParseError", code: 0))
        }

        let response = try JSONDecoder().decode(GraphQLOrdersResponse.self, from: data)

        return response.data.orders.map { graphQLOrder in
            Order(
                id: Int(graphQLOrder.id) ?? 0,
                description: graphQLOrder.description,
                price: graphQLOrder.price,
                customerID: Int(graphQLOrder.customerID) ?? 0,
                imageURL: graphQLOrder.imageURL,
                status: OrderStatus(rawValue: graphQLOrder.status.lowercased()) ?? .pending
            )
        }
    }

    private func parseCustomersFromGraphQLResponse(_ jsonString: String) throws -> [Customer] {
        guard let data = jsonString.data(using: .utf8) else {
            throw NetworkError.decodingError(NSError(domain: "ParseError", code: 0))
        }

        let response = try JSONDecoder().decode(GraphQLCustomersResponse.self, from: data)

        return response.data.customers.map { graphQLCustomer in
            Customer(
                id: Int(graphQLCustomer.id) ?? 0,
                name: graphQLCustomer.name,
                latitude: graphQLCustomer.latitude,
                longitude: graphQLCustomer.longitude
            )
        }
    }
}
