//
//  GraphQLOrderService.swift
//  Networking
//
//  Created by User on 6/5/25.
//

import Foundation

public class GraphQLOrderService {
    private let session: URLSession
    private let baseURL = "https://ba8312ca-45f2-4ed3-86b6-047cf8926e92.mock.pstmn.io/graphql"

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchOrders() async throws -> [Order] {
        print("Using GraphQL OrderService - fetching orders")

        let query = """
        {
          orders {
            id
            description
            price
            customerID
            imageURL
            status
          }
        }
        """

        let response = try await executeGraphQLQuery(query: query)
        print("GraphQL Orders Response: \(String(data: response, encoding: .utf8) ?? "Unable to decode")")
        
        let graphqlResponse = try JSONDecoder().decode(GraphQLOrdersResponse.self, from: response)
        let orders: [Order] = graphqlResponse.data.orders.compactMap { graphQLOrder in
            // Handle missing or invalid status field by defaulting to .new
            let status = graphQLOrder.status.flatMap { OrderStatus(rawValue: $0) } ?? .new
            
            return Order(
                id: graphQLOrder.id,
                description: graphQLOrder.description,
                price: graphQLOrder.price,
                customerID: graphQLOrder.customerID,
                imageURL: graphQLOrder.imageURL,
                status: status
            )
        }
        
        print("GraphQL: Successfully parsed \(orders.count) orders")
        return orders
    }

    public func fetchCustomers() async throws -> [Customer] {
        print("Using GraphQL OrderService - fetching customers")

        let query = """
        {
          customers {
            id
            name
            latitude
            longitude
          }
        }
        """

        let response = try await executeGraphQLQuery(query: query)
        print("GraphQL Customers Response: \(String(data: response, encoding: .utf8) ?? "Unable to decode")")
        
        let graphqlResponse = try JSONDecoder().decode(GraphQLCustomersResponse.self, from: response)
        let customers = graphqlResponse.data.customers.map { graphQLCustomer in
            Customer(
                id: graphQLCustomer.id,
                name: graphQLCustomer.name,
                latitude: graphQLCustomer.latitude,
                longitude: graphQLCustomer.longitude
            )
        }
        
        print("GraphQL: Successfully fetched \(customers.count) customers")
        return customers
    }

    private func executeGraphQLQuery(query: String) async throws -> Data {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("GraphQL HTTP Status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
