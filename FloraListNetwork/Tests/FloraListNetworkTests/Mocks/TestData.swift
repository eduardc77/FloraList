//
//  TestData.swift
//  FloraListNetwork
//
//  Created by User on 6/9/25.
//

@testable import FloraListNetwork

enum TestData {

    static var orders: [Order] {
        return [
            Order(id: 1, description: "Roses Bouquet", price: 45.99, customerID: 143, imageURL: "", status: .new),
            Order(id: 2, description: "Lilies Arrangement", price: 62.50, customerID: 223, imageURL: "", status: .pending)
        ]
    }

    static var customers: [Customer] {
        return [
            Customer(id: 143, name: "Cristina", latitude: 46.7712, longitude: 23.6236),
            Customer(id: 223, name: "Maria", latitude: 46.7650, longitude: 23.6200)
        ]
    }
}
