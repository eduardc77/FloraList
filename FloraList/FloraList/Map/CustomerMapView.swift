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
    @State private var selectedCustomer: Customer?
    @State private var showingCustomerOrders = false
    @State private var showRoutes = false
    @State private var routes: [MKRoute] = []

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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if showRoutes {
                            hideRoutes()
                        } else {
                            showOrderRoutes()
                        }
                    } label: {
                        Image(systemName: showRoutes ? "location.fill" : "location")
                    }
                }
            }
            .sheet(item: $selectedCustomer) { customer in
                CustomerOrdersSheet(customer: customer)
            }
        }
    }

    // MARK: - Subviews

    private var mapView: some View {
        MapView(
            customers: orderManager.customers,
            selectedCustomer: $selectedCustomer,
            userLocation: locationManager.currentLocation?.coordinate,
            showRoutes: $showRoutes,
            routes: routes
        )
        .onChange(of: selectedCustomer) { _, customer in
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
    }
    
    private func hideRoutes() {
        showRoutes = false
        routes = []
    }
}

#Preview {
    CustomerMapView()
        .environment(OrderManager())
        .environment(LocationManager())
}
