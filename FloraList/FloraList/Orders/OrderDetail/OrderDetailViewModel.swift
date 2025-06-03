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
    var order: Order
    let customer: Customer?

    init(order: Order, customer: Customer?) {
        self.order = order
        self.customer = customer
    }

    func updateStatus(_ newStatus: OrderStatus) {
        order.status = newStatus
    }
}
