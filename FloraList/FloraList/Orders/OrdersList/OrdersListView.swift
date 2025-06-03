//
//  OrdersListView.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import Networking

struct OrdersListView: View {
    @State private var viewModel = OrdersListViewModel()

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage, viewModel.orders.isEmpty {
                    errorView(errorMessage)
                } else {
                    ordersView
                }
            }
            .listStyle(.plain)
            .navigationTitle("Orders")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadOrders()
            }
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
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

    private var ordersView: some View {
        ForEach(viewModel.orders) { order in
            NavigationLink {
                OrderDetailView(order: order, customer: viewModel.customer(for: order))
            } label: {
                OrderRowView(order: order, customer: viewModel.customer(for: order))
            }
        }
    }
}

#Preview {
    OrdersListView()
}
