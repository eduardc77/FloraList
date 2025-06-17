//
//  TestData.swift
//  FloraListNetwork
//
//  Created by User on 6/9/25.
//

@testable import FloraListNetwork
@testable import FloraListDomain

enum TestData {

    static var orderDTOs: [OrderDTO] {
        return [
            OrderDTO(id: 1, description: "Roses Bouquet", price: 45.99, customerId: 143, imageUrl: "", status: "new"),
            OrderDTO(id: 2, description: "Lilies Arrangement", price: 62.50, customerId: 223, imageUrl: "", status: "pending")
        ]
    }

    static var customerDTOs: [CustomerDTO] {
        return [
            CustomerDTO(id: 143, name: "Cristina", latitude: 46.7712, longitude: 23.6236),
            CustomerDTO(id: 223, name: "Maria", latitude: 46.7650, longitude: 23.6200)
        ]
    }
    
    // Keep domain model versions for tests that need them
    static var orders: [Order] {
        return orderDTOs.map { $0.toDomain() }
    }

    static var customers: [Customer] {
        return customerDTOs.map { $0.toDomain() }
    }
}
