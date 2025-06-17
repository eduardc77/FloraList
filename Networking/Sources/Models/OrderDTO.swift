//
//  OrderDTO.swift
//  Networking
//
//  Created by User on 6/17/25.
//

struct OrderDTO: Codable {
    let id: Int
    let description: String
    let price: Double
    let customerId: Int
    let imageUrl: String
    let status: String?
}
