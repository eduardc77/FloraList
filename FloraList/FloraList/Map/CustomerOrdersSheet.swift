//
//  CustomerOrdersSheet.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import Networking

struct CustomerOrdersSheet: View {
    @Environment(OrderManager.self) private var orderManager
    @Environment(LocationManager.self) private var locationManager
    @Environment(DeepLinkManager.self) private var deepLinkManager
    @Environment(\.selectedTab) private var selectedTab
    @Environment(\.dismiss) private var dismiss
    let customer: Customer

    private var customerOrders: [Order] {
        orderManager.orders.filter { $0.customerID == customer.id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(customer.name)
                                    .font(.headline)
                                Text("Customer ID: \(customer.id)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }

                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.green)
                            Text("Lat: \(customer.latitude, specifier: "%.6f"), Lon: \(customer.longitude, specifier: "%.6f")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        DistanceInfoLabel(customer: customer, locationManager: locationManager)
                    }
                    .padding(.vertical, 4)
                }

                Section("Orders (\(customerOrders.count))") {
                    if customerOrders.isEmpty {
                        ContentUnavailableView {
                            Label("No Orders", systemImage: "list.bullet")
                        } description: {
                            Text("This customer hasn't placed any orders yet.")
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(customerOrders) { order in
                            OrderRowView(order: order, customer: customer)
                        }
                    }
                }

                if !customerOrders.isEmpty {
                    Section {
                        ForEach(customerOrders) { order in
                            Button {
                                Task {
                                    await navigateToOrder(order)
                                }
                            } label: {
                                Text("View Order Details")
                                    .foregroundStyle(.blue)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listSectionSpacing(20)
            .contentMargins(.top, 16, for: .scrollContent)
            .navigationTitle("Customer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func navigateToOrder(_ order: Order) async {
        do {
            guard let url = URL(string: "floralist://orders/\(order.id)") else {
                print("Failed to create deep link URL for order \(order.id)")
                return
            }
            
            // Switch to Orders tab first, then dismiss and navigate
            selectedTab.wrappedValue = .orders
            dismiss()
            
            // Handle the deep link - SwiftUI will coordinate the timing
            try await deepLinkManager.handle(url)
        } catch {
            print("Failed to navigate to order \(order.id): \(error)")
        }
    }
}
