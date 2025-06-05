//
//  ServiceFactory.swift
//  Networking
//
//  Created by User on 6/5/25.
//

public enum NetworkingType {
    case rest
    case graphQL
}

public struct ServiceFactory {
    public static func createOrderService(type: NetworkingType = .graphQL) -> OrderServiceProtocol {
        switch type {
        case .rest:
            return OrderService()
        case .graphQL:
            return GraphQLOrderService()
        }
    }
}
