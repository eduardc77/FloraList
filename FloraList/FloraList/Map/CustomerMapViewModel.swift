//
//  CustomerMapViewModel.swift
//  FloraList
//
//  Created by User on 6/6/25.
//

import Observation
import MapKit
import Networking

@Observable
final class CustomerMapViewModel {
    private let orderManager: OrderManager
    private let locationManager: LocationManager

    var showRoutes = true
    var routes: [MKRoute] = []

    var customers: [Customer] {
        orderManager.customers
    }

    var isLoading: Bool {
        orderManager.isLoading
    }

    var error: Error? {
        orderManager.error
    }

    init(orderManager: OrderManager, locationManager: LocationManager) {
        self.orderManager = orderManager
        self.locationManager = locationManager
    }

    // MARK: - Route Management

    @MainActor
    func showOrderRoutes() async {
        routes.removeAll()

        var calculatedRoutes: [MKRoute] = []

        for customer in customers {
            do {
                if let route = try await locationManager.calculateRoute(to: customer) {
                    calculatedRoutes.append(route)
                }
            } catch {
                print("Failed to calculate route to \(customer.name): \(error)")
            }
        }

        routes = calculatedRoutes
        showRoutes = true
    }

    func hideRoutes() {
        showRoutes = false
        // Properly clear routes to prevent MapKit leaks
        routes.removeAll()
    }

    func toggleRoutes() async {
        if showRoutes {
            hideRoutes()
        } else {
            await showOrderRoutes()
        }
    }

    @MainActor
    func retryDataFetch() async {
        await orderManager.fetchData()
    }
}
