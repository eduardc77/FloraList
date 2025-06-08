//
//  CustomerAnnotation.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import MapKit
import Networking

final class CustomerAnnotation: NSObject, MKAnnotation {
    let customer: Customer

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: customer.latitude, longitude: customer.longitude)
    }

    var title: String? {
        customer.name
    }

    var subtitle: String? {
        "Customer ID: \(customer.id)"
    }

    init(customer: Customer) {
        self.customer = customer
        super.init()
    }
}

