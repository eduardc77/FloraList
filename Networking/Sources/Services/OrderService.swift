//
//  OrderService.swift
//  Networking
//
//  Created by User on 6/3/25.
//

import Foundation

public class OrderService {
    private let baseURL = "http://demo7677712.mockable.io"
    private let session: URLSession

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    public init(session: URLSession = .shared) {
        self.session = session
    }

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
            let orderDTOs = try Self.decoder.decode([OrderDTO].self, from: data)
            let orders = orderDTOs.map(OrderMapper.map)
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
            let customerDTOs = try Self.decoder.decode([CustomerDTO].self, from: data)
            let customers = customerDTOs.map(CustomerMapper.map)
            print("REST: Successfully fetched \(customers.count) customers")
            return customers
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
