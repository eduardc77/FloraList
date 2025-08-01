//
//  RouteInfoLabel.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import SwiftUI
import FloraListDomain

struct RouteInfoLabel: View {
    let customer: Customer
    let locationManager: LocationManager
    var routeTime: String?
    var iconColor: Color = .orange
    var font: Font = .caption

    @State private var distance: String = String(localized: .calculatingDistance)

    var body: some View {
        if locationManager.isLocationAvailable {
            Label {
                if let routeTime = routeTime {
                    Text("\(distance) • \(routeTime)")
                        .font(font)
                        .foregroundStyle(.secondary)
                } else {
                    Text(distance)
                        .font(font)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "ruler")
                    .foregroundStyle(iconColor)
            }
            .task {
                distance = locationManager.formattedDistance(to: customer)
            }
        } else {
            Label {
                Text(.enableLocationForDistance)
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
        RouteInfoLabel(
            customer: Customer(id: 1, name: "John Doe", latitude: 46.562789, longitude: 23.784734),
            locationManager: LocationManager(),
            routeTime: "15 min"
        )
    }
    .padding()
}
