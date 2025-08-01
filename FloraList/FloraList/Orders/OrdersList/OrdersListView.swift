//
//  OrdersListView.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import FloraListDomain

struct OrdersListView: View {
    @Environment(OrderManager.self) private var orderManager
    @Environment(OrdersCoordinator.self) private var coordinator

    private var bindableCoordinator: Bindable<OrdersCoordinator> {
        Bindable(coordinator)
    }

    var body: some View {
        NavigationStack(path: bindableCoordinator.navigationPath) {
            OrdersListContentView(
                viewModel: OrdersListViewModel(
                    orderManager: orderManager
                )
            )
            .navigationDestination(for: OrdersCoordinator.Route.self) { route in
                switch route {
                case .orderDetail(let order):
                    OrderDetailView(
                        order: order,
                        customer: orderManager.customer(for: order)
                    )
                }
            }
        }
    }
}

private struct OrdersListContentView: View {
    @State private var viewModel: OrdersListViewModel
    @Environment(OrdersCoordinator.self) private var coordinator
    @Environment(AnalyticsManager.self) private var analytics

    init(viewModel: OrdersListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    private var hasActiveFilters: Bool {
        viewModel.selectedStatus != nil ||
        viewModel.selectedSortOption != nil ||
        !viewModel.searchText.isEmpty
    }

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.filteredAndSortedOrders.isEmpty {
                loadingView
            } else if let errorMessage = viewModel.errorMessage, viewModel.filteredAndSortedOrders.isEmpty {
                errorView(errorMessage)
            } else {
                ordersView
            }
        }
        .listStyle(.plain)
        .navigationTitle(Text(.orders))
        .searchable(text: $viewModel.searchText, prompt: Text(.searchOrders))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                filterSortMenu
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadOrders()
        }
        .onAppear {
            analytics.trackScreenView(screenName: "Orders List")
        }
    }

    // MARK: - Subviews

    private var ordersView: some View {
        Group {
            if viewModel.filteredAndSortedOrders.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.filteredAndSortedOrders) { order in
                    OrderCard(order: order, customer: viewModel.customer(for: order)) {
                        coordinator.showOrderDetail(order)
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            VStack {
                ProgressView()
                Text(.loadingOrders)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label {
                Text(.unableToLoadOrders)
            } icon: {
                Image(systemName: "wifi.exclamationmark")
            }
        } description: {
            Text(message)
        } actions: {
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Text(.tryAgain)
            }
            .buttonStyle(.borderedProminent)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Filter and Sort Menus

    private var filterSortMenu: some View {
        Menu {
            filterMenu
            sortMenu

            if viewModel.selectedStatus != nil ||
                viewModel.selectedSortOption != nil ||
                !viewModel.searchText.isEmpty {
                Divider()

                Button(role: .destructive) {
                    viewModel.clearFilters()
                } label: {
                    Label {
                        Text(.clearAll)
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        } label: {
            Label {
                Text(.filter)
            } icon: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(hasActiveFilters ? .fill : .none)
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            ForEach(OrderStatus.allCases, id: \.self) { status in
                Button {
                    viewModel.selectedStatus = viewModel.selectedStatus == status ? nil : status
                } label: {
                    HStack {
                        Label(status.displayName, systemImage: status.systemImage)
                            .foregroundStyle(status.color)
                        Spacer()
                        if viewModel.selectedStatus == status {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label {
                Text(.filterByStatus)
            } icon: {
                Image(systemName: "tag")
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(OrdersListViewModel.SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.selectedSortOption = viewModel.selectedSortOption == option ? nil : option
                } label: {
                    HStack {
                        Text(option.displayName)
                        Spacer()
                        if viewModel.selectedSortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label {
                Text(.sortOrders)
            } icon: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }
}

#Preview {
    OrdersListView()
}
