//
//  OrderService.swift
//  Networking
//
//  Created by User on 6/3/25.
//

import Foundation

public class OrderService {
    private let baseURL = "http://demo7677712.mockable.io"
    private let session = URLSession.shared

    public init() {}

    public func fetchOrders() async throws -> [Order] {
        print("Using REST OrderService - fetching orders")
        
        guard let url = URL(string: "\(baseURL)/orders") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }

        do {
            let orders = try JSONDecoder().decode([Order].self, from: data)
            print("REST: Successfully fetched \(orders.count) orders")
            return orders
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    public func fetchCustomers() async throws -> [Customer] {
        print("Using REST OrderService - fetching customers")
        
        guard let url = URL(string: "\(baseURL)/customers") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }

        do {
            let customers = try JSONDecoder().decode([Customer].self, from: data)
            print("REST: Successfully fetched \(customers.count) customers")
            return customers
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
