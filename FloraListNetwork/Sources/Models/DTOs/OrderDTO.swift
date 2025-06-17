//
//  OrderDTO.swift
//  FloraListNetwork
//
//  Created by User on 6/17/25.
//

import FloraListDomain

struct OrderDTO: Codable {
    let id: Int
    let description: String
    let price: Double
    let customerId: Int
    let imageUrl: String
    let status: String?

    func toDomain() -> Order {
        Order(
            id: id,
            description: description,
            price: price,
            customerID: customerId,
            imageURL: imageUrl,
            status: OrderStatus(rawValue: status ?? "") ?? .new
        )
    }
}
