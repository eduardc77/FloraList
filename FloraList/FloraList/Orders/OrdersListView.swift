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
                } else {
                    ForEach(viewModel.orders) { order in
                        OrderRowView(order: order, customer: viewModel.customer(for: order))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Orders")
            .task {
                await viewModel.loadOrders()
            }
        }
    }
}

#Preview {
    OrdersListView()
}
