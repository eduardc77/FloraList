//
//  CustomerMapViewModelTests.swift
//  FloraList
//
//  Created by User on 6/6/25.
//

import Testing
@testable import FloraList

struct CustomerMapViewModelTests {

    @Test("Toggle routes changes showRoutes state")
    func toggleRoutesChangesState() async {
        let orderManager = OrderManager(notificationManager: NotificationManager())
        let locationManager = LocationManager()
        let viewModel = CustomerMapViewModel(orderManager: orderManager, locationManager: locationManager)

        let initialState = viewModel.showRoutes

        await viewModel.toggleRoutes()

        #expect(viewModel.showRoutes == !initialState)
    }
}
