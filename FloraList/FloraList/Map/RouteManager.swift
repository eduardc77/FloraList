//
//  RouteManager.swift
//  FloraList
//
//  Created by User on 6/10/25.
//

import Observation
import MapKit
import FloraListDomain

@Observable
final class RouteManager {
    private let locationManager: LocationManager

    var currentRoute: MKRoute?
    var routeDestinationCustomer: Customer?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    @MainActor
    func showRoute(to customer: Customer) async {
        do {
            if let route = try await locationManager.calculateRoute(to: customer) {
                currentRoute = route
                routeDestinationCustomer = customer
            }
        } catch {
            clearRoute()
        }
    }

    func clearRoute() {
        currentRoute = nil
        routeDestinationCustomer = nil
    }

    func isRouteShown(for customer: Customer) -> Bool {
        routeDestinationCustomer?.id == customer.id
    }
    
    func clearRouteIfDestinationNotFound(in customers: [Customer]) {
        guard let routeDestination = routeDestinationCustomer else { return }
        
        // Check if the route destination customer still exists in the current customer list
        let customerExists = customers.contains { $0.id == routeDestination.id }
        
        if !customerExists {
            clearRoute()
        }
    }

    static func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}
