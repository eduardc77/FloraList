//
//  OrdersListView.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import Networking

struct OrdersListView: View {
    @Environment(OrderManager.self) private var orderManager
    @Environment(OrdersCoordinator.self) private var coordinator

    var body: some View {
        OrdersListContentView(
            viewModel: OrdersListViewModel(
                orderManager: orderManager
            )
        )
    }
}

private struct OrdersListContentView: View {
    @State private var viewModel: OrdersListViewModel
    @Environment(OrdersCoordinator.self) private var coordinator

    init(viewModel: OrdersListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    private var bindableCoordinator: Bindable<OrdersCoordinator> {
        Bindable(coordinator)
    }

    private var hasActiveFilters: Bool {
        viewModel.selectedStatus != nil ||
        viewModel.selectedSortOption != nil ||
        !viewModel.searchText.isEmpty
    }

    var body: some View {
        NavigationStack(path: bindableCoordinator.navigationPath) {
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
            .navigationTitle("Orders")
            .searchable(text: $viewModel.searchText, prompt: "Search orders...")
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
            .navigationDestination(for: OrdersCoordinator.Route.self) { route in
                switch route {
                case .orderDetail(let order):
                    OrderDetailView(
                        order: order,
                        customer: viewModel.customer(for: order)
                    )
                }
            }
        }
    }

    // MARK: - Subviews

    private var ordersView: some View {
        Group {
            if viewModel.filteredAndSortedOrders.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                ForEach(viewModel.filteredAndSortedOrders) { order in
                    Button {
                        coordinator.showOrderDetail(order)
                    } label: {
                        OrderRowView(order: order, customer: viewModel.customer(for: order))
                    }
                    .contentShape(.rect)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            VStack {
                ProgressView()
                Text("Loading orders...")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Orders", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task { await viewModel.refresh() }
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
                    Label("Clear All", systemImage: "xmark.circle.fill")
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(hasActiveFilters ? .fill : .none)
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
            Label("Filter by Status", systemImage: "tag")
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(OrdersListViewModel.SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.selectedSortOption = viewModel.selectedSortOption == option ? nil : option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        Spacer()
                        if viewModel.selectedSortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Sort Orders", systemImage: "arrow.up.arrow.down")
        }
    }
}

#Preview {
    OrdersListView()
}
