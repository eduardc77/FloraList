//
//  CustomerOrdersSheetViewModelTests.swift
//  FloraList
//
//  Created by User on 6/8/25.
//

import Testing
import SwiftUI
import Networking
@testable import FloraList

@Suite("Customer Orders Sheet")
struct CustomerOrdersSheetViewModelTests {
    
    @Test("Deep-link Navigation switches tab and dismisses")
    @MainActor func navigationSwitchesTabAndDismisses() async {
        let testOrder = MockOrderManager.sampleOrder
        let testCustomer = MockOrderManager.sampleCustomer
        
        var selectedTab: AppTab = .map
        let binding = Binding(get: { selectedTab }, set: { selectedTab = $0 })
        
        var dismissed = false
        let mockDeepLinkManager = MockDeepLinkManager()
        
        let viewModel = CustomerOrdersSheetViewModel(
            customer: testCustomer,
            orderManager: OrderManager(notificationManager: NotificationManager()),
            locationManager: LocationManager(),
            deepLinkManager: mockDeepLinkManager,
            selectedTab: binding,
            dismiss: { dismissed = true }
        )
        
        await viewModel.navigateToOrder(testOrder)
        
        #expect(selectedTab == .orders)
        #expect(dismissed == true)
    }
}
 
