//
//  OrderDetailViewModel.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import Foundation
import Networking

@Observable
final class OrderDetailViewModel {
    private let orderManager: OrderManager
    private let deepLinkManager: DeepLinkManager
    var order: Order
    let customer: Customer?

    init(order: Order,
         customer: Customer?,
         orderManager: OrderManager,
         deepLinkManager: DeepLinkManager) {
        self.order = order
        self.customer = customer
        self.orderManager = orderManager
        self.deepLinkManager = deepLinkManager
    }

    func updateStatus(_ newStatus: OrderStatus) {
        let oldStatus = order.status
        
        // Update shared state through the manager (includes analytics & notifications)
        Task {
            do {
                try await orderManager.updateOrderStatus(order, status: newStatus)
                
                // Update local order object for immediate UI update
                order.status = newStatus
            } catch {
                print("Failed to update order status: \(error)")
                // Revert local status on error
                order.status = oldStatus
            }
        }
    }
    
    func navigateToCustomerOnMap(_ customer: Customer) async {
        do {
            guard let url = URL(string: "floralist://map/customer/\(customer.id)") else {
                print("Failed to create deep link URL for customer \(customer.id)")
                return
            }
            
            // Handle the deep link
            try await deepLinkManager.handle(url)
        } catch {
            print("Failed to navigate to customer \(customer.id): \(error)")
        }
    }
}
