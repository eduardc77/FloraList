//
//  DistanceInfoLabel.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import SwiftUI
import Networking

struct DistanceInfoLabel: View {
    let customer: Customer
    let locationManager: LocationManager
    var iconColor: Color = .orange
    var font: Font = .caption

    var body: some View {
        if locationManager.isLocationAvailable {
            Label {
                Text("\(locationManager.formattedDistance(to: customer)) away")
                    .font(font)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "ruler")
                    .foregroundStyle(iconColor)
            }
        } else {
            Label {
                Text("Enable location for distance")
                    .font(font)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "location.slash")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        DistanceInfoLabel(
            customer: Customer(id: 1, name: "John Doe", latitude: 46.562789, longitude: 23.784734),
            locationManager: LocationManager()
        )
    }
    .padding()
}
