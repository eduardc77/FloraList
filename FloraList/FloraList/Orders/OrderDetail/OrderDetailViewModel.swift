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
    var notificationManager: NotificationManager
    var order: Order
    let customer: Customer?
    @ObservationIgnored private let analyticsManager = AnalyticsManager.shared

    init(order: Order,
         customer: Customer?,
         notificationManager: NotificationManager) {
        self.order = order
        self.customer = customer
        self.notificationManager = notificationManager
    }

    func updateStatus(_ newStatus: OrderStatus) {
        let oldStatus = order.status
        order.status = newStatus

        // Track status update if it actually changed
        if oldStatus != newStatus {
            analyticsManager.trackOrderStatusUpdate(
                orderId: order.id,
                oldStatus: oldStatus.displayName,
                newStatus: newStatus.displayName
            )
        }

        // Only notify if order status changed and notifications are allowed
        if oldStatus != newStatus && notificationManager.isPermissionGranted {
            print("Status changed from \(oldStatus) to \(newStatus)")
            Task {
                do {
                    try await notificationManager.scheduleOrderStatusNotification(
                        orderId: order.id,
                        description: order.description,
                        status: order.status.displayName.lowercased()
                    )
                } catch {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }
}
