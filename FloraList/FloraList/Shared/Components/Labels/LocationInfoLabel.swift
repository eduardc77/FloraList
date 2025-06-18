//
//  LocationInfoLabel.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import FloraListDomain

struct LocationInfoLabel: View {
    let customer: Customer
    var iconColor: Color = .green
    var font: Font = .subheadline

    var body: some View {
        Label {
            Text(coordinateText)
                .font(font)
        } icon: {
            Image(systemName: "location.fill")
                .foregroundStyle(iconColor)
        }
    }

    private var coordinateText: String {
        let latitude = String(format: "%.6f", customer.latitude)
        let longitude = String(format: "%.6f", customer.longitude)
        return String(localized: .latitudeLongitudeFormat(latitude, longitude))
    }
}

#Preview {
    VStack(alignment: .leading) {
        LocationInfoLabel(
            customer: Customer(id: 1, name: "John Doe", latitude: 46.562789, longitude: 23.784734)
        )
    }
    .padding()
}
