//
//  OrdersListViewModelTests.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import Testing
import Networking
@testable import FloraList

@Suite("Orders List ViewModel")
struct OrdersListViewModelTests {

    let mockOrderManager = MockOrderManager.withTestData()

    @Test("ViewModel filtering and sorting works correctly")
    func viewModelFilteringAndSortingWorksCorrectly() {
        let viewModel = OrdersListViewModel(orderManager: mockOrderManager)

        #expect(viewModel.filteredAndSortedOrders.count == 4)

        viewModel.searchText = "roses"
        #expect(viewModel.filteredAndSortedOrders.count == 1)
        #expect(viewModel.filteredAndSortedOrders.first?.description == "Roses Bouquet")

        viewModel.searchText = ""
        viewModel.selectedStatus = .new
        #expect(viewModel.filteredAndSortedOrders.count == 2)
        #expect(viewModel.filteredAndSortedOrders.allSatisfy { $0.status == .new })
    }
} 
