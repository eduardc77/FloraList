//
//  OrderDetailView.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import Networking

struct OrderDetailView: View {
    let order: Order
    let customer: Customer?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                orderImageSection
                orderInfoSection
                customerSection
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var orderImageSection: some View {
        AsyncImage(url: URL(string: order.imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .overlay {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var orderInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(order.description)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("$\(order.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Order #\(order.id)", systemImage: "number")
                Spacer()
                statusBadge
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var customerSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Customer Information")
                        .font(.headline)
                    Spacer()
                }

                if let customer = customer {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(customer.name, systemImage: "person.fill")
                        Label("Location: (\(customer.latitude), \(customer.longitude))", systemImage: "location.fill")
                    }
                    .font(.subheadline)
                } else {
                    Text("Customer information unavailable")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var statusBadge: some View {
        Text(order.status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(order.status.color.opacity(0.2))
            .foregroundStyle(order.status.color)
            .clipShape(Capsule())
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
}
