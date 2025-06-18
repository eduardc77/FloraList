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
            .navigationTitle(Text(.customerDetails))
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
                            Text(String(localized: .customerIdFormat(String(viewModel.customer.id))))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.green)
                        Text(String(localized: .latitudeLongitudeFormat(
                            String(format: "%.6f", viewModel.customer.latitude),
                            String(format: "%.6f", viewModel.customer.longitude)
                        )))
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

            Section {
                if !viewModel.hasOrders {
                    ContentUnavailableView {
                        Label {
                            Text(.noOrdersYet)
                        } icon: {
                            Image(systemName: "list.bullet")
                        }
                    } description: {
                        Text(.customerNoOrdersMessage)
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
            } header: {
                Text(.ordersWithCount(viewModel.ordersCount))
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
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    viewModel.dismissSheet()
                } label: {
                    Text(.done)
                }
            }
        }
    }
}
