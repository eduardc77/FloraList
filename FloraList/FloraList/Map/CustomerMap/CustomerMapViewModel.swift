//
//  CustomerMapViewModel.swift
//  FloraList
//
//  Created by User on 6/6/25.
//

import Observation
import MapKit
import FloraListDomain

@Observable
final class CustomerMapViewModel {
    private let orderManager: OrderManager
    private let routeManager: RouteManager

    var customers: [Customer] {
        orderManager.customers
    }

    var isLoading: Bool {
        orderManager.isLoading
    }

    var error: Error? {
        orderManager.error
    }

    init(orderManager: OrderManager, routeManager: RouteManager) {
        self.orderManager = orderManager
        self.routeManager = routeManager
    }

    // MARK: - Route Management
    
    var currentRoute: MKRoute? {
        routeManager.currentRoute
    }
    
    var routeDestinationCustomer: Customer? {
        routeManager.routeDestinationCustomer
    }
    
    @MainActor
    func retryDataFetch() async {
        await orderManager.fetchData()
    }
}
