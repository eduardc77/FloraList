//
//  Customer.swift
//  FloraListDomain
//
//  Created by User on 6/3/25.
//

public struct Customer: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let latitude: Double
    public let longitude: Double

    public init(id: Int, name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
