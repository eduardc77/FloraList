//
//  CustomerDTO.swift
//  FloraListNetwork
//
//  Created by User on 6/17/25.
//

import FloraListDomain

struct CustomerDTO: Codable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double

    func toDomain() -> Customer {
        Customer(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude
        )
    }
}
