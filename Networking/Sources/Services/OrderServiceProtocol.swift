//
//  OrderServiceProtocol.swift
//  Networking
//
//  Created by User on 6/5/25.
//

public protocol OrderServiceProtocol {
    func fetchOrders() async throws -> [Order]
    func fetchCustomers() async throws -> [Customer]
}

extension OrderService: OrderServiceProtocol {}
extension GraphQLOrderService: OrderServiceProtocol {}
