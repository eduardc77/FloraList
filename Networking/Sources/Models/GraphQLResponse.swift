//
//  GraphQLResponse.swift
//  Networking
//
//  Created by User on 6/5/25.
//

struct GraphQLOrdersResponse: Codable {
    let data: GraphQLOrdersData
}

struct GraphQLOrdersData: Codable {
    let orders: [GraphQLOrder]
}

struct GraphQLOrder: Codable {
    let id: Int
    let description: String
    let price: Double
    let customerID: Int
    let imageURL: String
    let status: String?
}

struct GraphQLCustomersResponse: Codable {
    let data: GraphQLCustomersData
}

struct GraphQLCustomersData: Codable {
    let customers: [GraphQLCustomer]
}

struct GraphQLCustomer: Codable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
}
