//
//  OrderDetailViewModel.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import Observation
import Networking

@Observable
final class OrderDetailViewModel {
    private let orderManager: OrderManager
    var order: Order
    let customer: Customer?

    init(order: Order,
         customer: Customer?,
         orderManager: OrderManager) {
        self.order = order
        self.customer = customer
        self.orderManager = orderManager
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
}
