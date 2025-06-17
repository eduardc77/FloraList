//
//  CustomerOrdersSheet.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import FloraListDomain

struct CustomerOrdersSheet: View {
    @Environment(OrderManager.self) private var orderManager
    @Environment(DeepLinkManager.self) private var deepLinkManager
    @Environment(RouteManager.self) private var routeManager
    @Environment(\.selectedTab) private var selectedTab
    @Environment(\.dismiss) private var dismiss
    let customer: Customer

    var body: some View {
        NavigationStack {
            CustomerOrdersSheetContentView(
                viewModel: CustomerOrdersSheetViewModel(
                    customer: customer,
                    orderManager: orderManager,
                    deepLinkManager: deepLinkManager,
                    selectedTab: selectedTab,
                    dismiss: { dismiss() },
                    routeManager: routeManager
                )
            )
            .navigationTitle("Customer Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct CustomerOrdersSheetContentView: View {
    @State private var viewModel: CustomerOrdersSheetViewModel
    @Environment(LocationManager.self) private var locationManager

    init(viewModel: CustomerOrdersSheetViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(viewModel.customer.name)
                                .font(.headline)
                            Text("Customer ID: \(viewModel.customer.id)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.green)
                        Text("Lat: \(viewModel.customer.latitude, specifier: "%.6f"), Lon: \(viewModel.customer.longitude, specifier: "%.6f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    RouteInfoLabel(
                        customer: viewModel.customer,
                        locationManager: locationManager,
                        routeTime: viewModel.isRouteShown ? viewModel.currentRouteTime : nil
                    )
                }
                .padding(.vertical, 4)
            }

            Section("Orders (\(viewModel.ordersCount))") {
                if !viewModel.hasOrders {
                    ContentUnavailableView {
                        Label("No Orders", systemImage: "list.bullet")
                    } description: {
                        Text("This customer hasn't placed any orders yet.")
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.customerOrders) { order in
                        OrderCard(order: order, customer: viewModel.customer) {
                            Task {
                                await viewModel.navigateToOrder(order)
                            }
                        }
                    }
                }
            }
        }
        .listSectionSpacing(16)
        .contentMargins(.top, 16, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task {
                        if viewModel.isRouteShown {
                            viewModel.clearRoute()
                        } else {
                            await viewModel.showRoute()
                        }
                    }
                } label: {
                    Image(systemName: viewModel.isRouteShown
                          ? "point.topleft.down.curvedto.point.bottomright.up.fill"
                          : "point.topleft.down.curvedto.point.bottomright.up")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    viewModel.dismissSheet()
                }
            }
        }
    }
}
