//
//  CustomerMapView.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import MapKit
import Networking

struct CustomerMapView: View {
    @Environment(OrderManager.self) private var orderManager
    @Environment(LocationManager.self) private var locationManager
    @Environment(CustomerMapCoordinator.self) private var coordinator
    @Environment(AnalyticsManager.self) private var analytics
    
    var body: some View {
        NavigationStack {
            CustomerMapContentView(
                viewModel: CustomerMapViewModel(
                    orderManager: orderManager,
                    locationManager: locationManager
                )
            )
            .navigationTitle("Customer Locations")
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
    @Environment(AnalyticsManager.self) private var analytics
    @Environment(LocationManager.self) private var locationManager
    @State private var showingCustomerOrders = false
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Routes toggle button
                Button {
                    Task {
                        await viewModel.toggleRoutes()
                    }
                } label: {
                    Image(systemName: viewModel.showRoutes ? "point.topleft.down.curvedto.point.bottomright.up.fill" : "point.topleft.down.curvedto.point.bottomright.up")
                }
                
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
            showRoutes: .constant(viewModel.showRoutes),
            routes: viewModel.routes,
            shouldCenterOnUser: $shouldCenterOnUser,
            isCenteredOnUser: $isCenteredOnUser
        )
        .task {
            // Calculate routes on initial load since showRoutes is true by default
            if viewModel.showRoutes && viewModel.routes.isEmpty {
                await viewModel.showOrderRoutes()
            }
        }
        .onChange(of: coordinator.selectedCustomer) { _, customer in
            if customer != nil {
                showingCustomerOrders = true
            }
        }
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading customer locations...")
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Locations", systemImage: "map.fill")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task { 
                    await viewModel.retryDataFetch()
                }
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
