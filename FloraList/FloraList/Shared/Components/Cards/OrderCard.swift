//
//  OrderCard.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import FloraListDomain

struct OrderCard: View {
    let order: Order
    let customer: Customer?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                orderImage(size: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.description)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    if let customer = customer {
                        Text(customer.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    HStack {
                        statusBadge
                        Spacer()
                        Text("$\(order.price, specifier: "%.0f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 2)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subviews

    private func orderImage(size: CGFloat) -> some View {
        AsyncImage(url: URL(string: order.imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(.quaternary)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                        .font(.system(size: size * 0.3))
                }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var statusBadge: some View {
        Text(order.status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(order.status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(order.status.color.opacity(0.15), in: Capsule())
    }
}

#Preview("Compact") {
    VStack(spacing: 8) {
        OrderCard(
            order: Order(id: 1, description: "Roses Bouquet", price: 45.99, customerID: 143, imageURL: "", status: .new),
            customer: Customer(id: 143, name: "Cristina", latitude: 46.7712, longitude: 23.6236),
            onTap: {}
        )
    }
    .padding()
}
