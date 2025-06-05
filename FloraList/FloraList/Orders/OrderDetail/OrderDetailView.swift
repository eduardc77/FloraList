//
//  OrderDetailView.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import Networking

struct OrderDetailView: View {
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(LocationManager.self) private var locationManager
    @Environment(DeepLinkManager.self) private var deepLinkManager
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
                notificationManager: notificationManager
            ),
            locationManager: locationManager
        )
    }
}

private struct OrderDetailContentView: View {
    let viewModel: OrderDetailViewModel
    let locationManager: LocationManager
    @Environment(DeepLinkManager.self) private var deepLinkManager
    @Environment(AnalyticsManager.self) private var analytics

    var body: some View {
        Form {
            orderImage
            orderInfo
            statusSection
            customerInfoSection
        }
        .listSectionSpacing(20)
        .navigationTitle(viewModel.order.description)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            analytics.trackScreenView(screenName: "Order Detail")
        }
    }

    // MARK: - Sections

    private var orderImage: some View {
        AsyncImage(url: URL(string: viewModel.order.imageURL)) { image in
            image
                .resizable()
                .frame(height: 300)
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 300)
                .overlay {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
    }

    private var orderInfo: some View {
        Section {
            VStack(alignment: .leading) {
                Text("$\(viewModel.order.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.medium)

                LabeledContent("Order #\(viewModel.order.id)") {
                    statusBadge
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var statusSection: some View {
        Section {
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
                    DistanceInfoLabel(customer: customer, locationManager: locationManager)
                }
                .font(.subheadline)
                
                // Deep link to customer on map
                Button {
                    Task {
                        await navigateToCustomerOnMap(customer)
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

    private var statusBadge: some View {
        Text(viewModel.order.status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(viewModel.order.status.color.opacity(0.2))
            .foregroundStyle(viewModel.order.status.color)
            .clipShape(Capsule())
    }

    // MARK: - Actions
    
    private func navigateToCustomerOnMap(_ customer: Customer) async {
        do {
            guard let url = URL(string: "floralist://map/customer/\(customer.id)") else {
                print("Failed to create deep link URL for customer \(customer.id)")
                return
            }
            
            // Handle the deep link
            try await deepLinkManager.handle(url)
        } catch {
            print("Failed to navigate to customer \(customer.id): \(error)")
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
    .environment(NotificationManager())
    .environment(LocationManager())
    .environment(DeepLinkManager())
}
