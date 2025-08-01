//
//  Order.swift
//  FloraListDomain
//
//  Created by User on 6/3/25.
//

public struct Order: Codable, Identifiable, Sendable, Equatable, Hashable {
    public let id: Int
    public let description: String
    public let price: Double
    public let customerID: Int
    public let imageURL: String
    public var status: OrderStatus

    public init(id: Int, description: String, price: Double, customerID: Int, imageURL: String, status: OrderStatus) {
        self.id = id
        self.description = description
        self.price = price
        self.customerID = customerID
        self.imageURL = imageURL
        self.status = status
    }
}
