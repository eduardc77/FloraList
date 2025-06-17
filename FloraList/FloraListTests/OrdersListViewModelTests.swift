//
//  OrdersListViewModelTests.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import Testing
@testable import FloraList

@Suite("Orders List ViewModel")
struct OrdersListViewModelTests {

    @Test("Search filtering works correctly")
    func searchFilteringWorksCorrectly() {
        let mockManager = MockOrderManager.withTestData()
        let viewModel = OrdersListViewModel(orderManager: mockManager)
        
        let initialCount = viewModel.filteredAndSortedOrders.count

        // Test search functionality
        viewModel.searchText = "roses"
        let filteredCount = viewModel.filteredAndSortedOrders.count

        #expect(filteredCount <= initialCount) // Filtering should reduce or keep the current count
        #expect(filteredCount > 0) // Should find roses in the test data
        #expect(viewModel.filteredAndSortedOrders.allSatisfy { 
            $0.description.localizedCaseInsensitiveContains("roses") 
        })
    }
    
    @Test("Status filtering works correctly")
    func statusFilteringWorksCorrectly() {
        let mockManager = MockOrderManager.withTestData()
        let viewModel = OrdersListViewModel(orderManager: mockManager)
        
        let initialCount = viewModel.filteredAndSortedOrders.count
        
        // Test status filtering
        viewModel.selectedStatus = .new
        let filteredCount = viewModel.filteredAndSortedOrders.count
        
        // Verify behavior
        #expect(filteredCount <= initialCount) // Filtering should reduce or keep the current count
        #expect(filteredCount > 0) // Should find orders with .new status in test data
        #expect(viewModel.filteredAndSortedOrders.allSatisfy { $0.status == .new })
    }
    
    @Test("Clearing filters resets to full list")
    func clearingFiltersResets() {
        let mockManager = MockOrderManager.withTestData()
        let viewModel = OrdersListViewModel(orderManager: mockManager)
        
        let originalCount = viewModel.filteredAndSortedOrders.count
        
        // Apply filters
        viewModel.searchText = "test"
        viewModel.selectedStatus = .pending
        
        // Clear filters
        viewModel.clearFilters()
        
        // Should return to original state
        #expect(viewModel.searchText == "")
        #expect(viewModel.selectedStatus == nil)
        #expect(viewModel.filteredAndSortedOrders.count == originalCount)
    }
} 
