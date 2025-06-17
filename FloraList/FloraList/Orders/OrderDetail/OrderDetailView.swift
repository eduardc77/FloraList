//
//  OrderDetailView.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import FloraListDomain

struct OrderDetailView: View {
    @Environment(LocationManager.self) private var locationManager
    @Environment(DeepLinkManager.self) private var deepLinkManager
    @Environment(OrderManager.self) private var orderManager
    private let order: Order
    private let customer: Customer?

    init(order: Order, customer: Customer?) {
        self.order = order
        self.customer = customer
    }

    var body: some View {
        OrderDetailContentView(
            viewModel: OrderDetailViewModel(
                order: order,
                customer: customer,
                orderManager: orderManager,
                deepLinkManager: deepLinkManager
            ),
            locationManager: locationManager
        )
    }
}

private struct OrderDetailContentView: View {
    let viewModel: OrderDetailViewModel
    let locationManager: LocationManager
    @Environment(AnalyticsManager.self) private var analytics

    var body: some View {
        Form {
            orderImage
            orderInfo
            statusSection
            customerInfoSection
        }
        .listSectionSpacing(16)
        .contentMargins(.top, 16, for: .scrollContent)
        .navigationTitle(viewModel.order.description)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            analytics.trackScreenView(screenName: "Order Detail")
        }
    }

    // MARK: - Subviews

    private var orderImage: some View {
        AsyncImage(url: URL(string: viewModel.order.imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 320)
                .clipped()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 320)
                .overlay {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
        }
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
    }

    private var orderInfo: some View {
        LabeledContent("Order #\(viewModel.order.id)") {
            Text("$\(viewModel.order.price, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .font(.callout)
        .foregroundStyle(.secondary)
        .padding(.vertical, 8)
    }

    private var statusSection: some View {
        Picker("Order Status", selection: .init(
            get: { viewModel.order.status },
            set: { viewModel.updateStatus($0) }
        )) {
            ForEach(OrderStatus.allCases, id: \.self) { status in
                Label(status.displayName, systemImage: status.systemImage)
                    .foregroundStyle(status.color)
                    .tag(status)
            }
        }
        .pickerStyle(.menu)
    }

    private var customerInfoSection: some View {
        Section {
            HStack {
                Text("Customer Information")
                    .font(.headline)
                Spacer()
            }

            if let customer = viewModel.customer {
                VStack(alignment: .leading, spacing: 8) {
                    Label(customer.name, systemImage: "person.fill")

                    LocationInfoLabel(customer: customer)

                    // Distance information
                    RouteInfoLabel(customer: customer, locationManager: locationManager)
                }
                .font(.subheadline)
                
                // Deep link to customer on map
                Button {
                    Task {
                        await viewModel.navigateToCustomerOnMap(customer)
                    }
                } label: {
                    Label("View on Map", systemImage: "map")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            } else {
                Text("Customer information unavailable")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(
            order: Order(
                id: 1,
                description: "Red Roses",
                price: 50.0,
                customerID: 1,
                imageURL: "https://example.com/image.jpg",
                status: .pending
            ),
            customer: Customer(id: 1, name: "John Doe", latitude: 46.562789, longitude: 23.784734)
        )
    }
    .environment(LocationManager())
    .environment(DeepLinkManager())
    .environment(OrderManager(notificationManager: NotificationManager()))
}
