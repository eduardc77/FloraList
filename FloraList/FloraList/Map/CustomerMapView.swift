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
    @State private var showingCustomerOrders = false
    @State private var showRoutes = true
    @State private var routes: [MKRoute] = []
    @State private var shouldCenterOnUser = false
    @State private var isCenteredOnUser = false

    var body: some View {
        NavigationStack {
            ZStack {
                if orderManager.isLoading {
                    loadingView
                } else if let error = orderManager.error {
                    errorView(error.localizedDescription)
                } else {
                    mapView
                }
            }
            .navigationTitle("Customer Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Routes toggle button
                    Button {
                        if showRoutes {
                            hideRoutes()
                        } else {
                            showOrderRoutes()
                        }
                    } label: {
                        Image(systemName: showRoutes ? "point.topleft.down.curvedto.point.bottomright.up.fill" : "point.topleft.down.curvedto.point.bottomright.up")
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
            .sheet(item: .init(
                get: { coordinator.selectedCustomer },
                set: { coordinator.selectedCustomer = $0 }
            )) { customer in
                CustomerOrdersSheet(customer: customer)
            }
        }
    }

    // MARK: - Subviews

    private var mapView: some View {
        MapView(
            customers: orderManager.customers,
            selectedCustomer: .init(
                get: { coordinator.selectedCustomer },
                set: { coordinator.selectedCustomer = $0 }
            ),
            userLocation: locationManager.currentLocation?.coordinate,
            showRoutes: $showRoutes,
            routes: routes,
            shouldCenterOnUser: $shouldCenterOnUser,
            isCenteredOnUser: $isCenteredOnUser
        )
        .task {
            // Calculate routes on initial load since showRoutes is true by default
            if showRoutes && routes.isEmpty {
                await showOrderRoutesAsync()
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
                Task { await orderManager.fetchData() }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Route Management
    
    private func showOrderRoutes() {
        Task {
            await showOrderRoutesAsync()
        }
    }
    
    private func showOrderRoutesAsync() async {
        var calculatedRoutes: [MKRoute] = []
        
        for customer in orderManager.customers {
            do {
                if let route = try await locationManager.calculateRoute(to: customer) {
                    calculatedRoutes.append(route)
                }
            } catch {
                print("Failed to calculate route to \(customer.name): \(error)")
            }
        }
        
        await MainActor.run {
            routes = calculatedRoutes
            showRoutes = true
        }
    }
    
    private func hideRoutes() {
        showRoutes = false
        routes = []
    }

    private func centerOnUserLocation() {
        shouldCenterOnUser = true
    }
}

#Preview {
    CustomerMapView()
        .environment(OrderManager())
        .environment(LocationManager())
}
