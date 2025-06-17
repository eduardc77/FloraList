//
//  CustomerMapViewModelTests.swift
//  FloraList
//
//  Created by User on 6/6/25.
//

import Testing
@testable import FloraList

struct CustomerMapViewModelTests {

    @Test("CustomerMapViewModel exposes correct properties from dependencies")
    func exposesCorrectProperties() {
        let orderManager = OrderManager(notificationManager: NotificationManager())
        let routeManager = RouteManager(locationManager: LocationManager())
        let viewModel = CustomerMapViewModel(orderManager: orderManager, routeManager: routeManager)

        // Test that view model properly exposes order manager properties
        #expect(viewModel.customers == orderManager.customers)
        #expect(viewModel.isLoading == orderManager.isLoading)
        #expect(viewModel.error == nil)

        // Test that view model properly exposes route manager properties
        #expect(viewModel.currentRoute == routeManager.currentRoute)
        #expect(viewModel.routeDestinationCustomer == routeManager.routeDestinationCustomer)
    }
}
