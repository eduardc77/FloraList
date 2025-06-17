//
//  ServiceFactory.swift
//  FloraListNetwork
//
//  Created by User on 6/5/25.
//

import FloraListDomain

public enum NetworkingType: Hashable {
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
