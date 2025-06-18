//
//  CustomerMapView.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import MapKit

struct CustomerMapView: View {
    @Environment(OrderManager.self) private var orderManager
    @Environment(RouteManager.self) private var routeManager
    @Environment(CustomerMapCoordinator.self) private var coordinator
    @Environment(AnalyticsManager.self) private var analytics
    
    var body: some View {
        NavigationStack {
            CustomerMapContentView(
                viewModel: CustomerMapViewModel(
                    orderManager: orderManager,
                    routeManager: routeManager
                )
            )
            .navigationTitle(Text(.customerLocations))
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: .init(
            get: { coordinator.selectedCustomer },
            set: { coordinator.selectedCustomer = $0 }
        )) { customer in
            CustomerOrdersSheet(customer: customer)
        }
        .onAppear {
            analytics.trackScreenView(screenName: "Customer Map")
        }
    }
}

private struct CustomerMapContentView: View {
    @State private var viewModel: CustomerMapViewModel
    @Environment(CustomerMapCoordinator.self) private var coordinator
    @Environment(LocationManager.self) private var locationManager
    @Environment(RouteManager.self) private var routeManager
    @State private var shouldCenterOnUser = false
    @State private var isCenteredOnUser = false
    
    init(viewModel: CustomerMapViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error.localizedDescription)
            } else {
                mapView
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Center on user location button
                if locationManager.isLocationAvailable {
                    Button {
                        centerOnUserLocation()
                    } label: {
                        Image(systemName: isCenteredOnUser ? "location.fill" : "location")
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var mapView: some View {
        MapView(
            customers: viewModel.customers,
            selectedCustomer: .init(
                get: { coordinator.selectedCustomer },
                set: { coordinator.selectedCustomer = $0 }
            ),
            userLocation: locationManager.currentLocation?.coordinate,
            showRoutes: .constant(viewModel.currentRoute != nil),
            routes: viewModel.currentRoute.map { [$0] } ?? [],
            routeManager: routeManager,
            locationManager: locationManager,
            shouldCenterOnUser: $shouldCenterOnUser,
            isCenteredOnUser: $isCenteredOnUser
        )
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
            Text(.loadingCustomerLocations)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label {
                Text(.unableToLoadLocations)
            } icon: {
                Image(systemName: "map.fill")
            }
        } description: {
            Text(message)
        } actions: {
            Button {
                Task { 
                    await viewModel.retryDataFetch()
                }
            } label: {
                Text(.tryAgain)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - User Location

    private func centerOnUserLocation() {
        shouldCenterOnUser = true
    }
}

#Preview {
    CustomerMapView()
        .environment(OrderManager(notificationManager: NotificationManager()))
        .environment(LocationManager())
        .environment(CustomerMapCoordinator())
        .environment(AnalyticsManager.shared)
}
