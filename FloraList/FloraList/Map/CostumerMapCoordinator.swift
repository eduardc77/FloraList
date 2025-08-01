//
//  CostumerMapCoordinator.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import Observation
import FloraListDomain

@Observable
final class CustomerMapCoordinator {
    var selectedCustomer: Customer?

    func showCustomer(_ customer: Customer) {
        selectedCustomer = customer
    }
}
