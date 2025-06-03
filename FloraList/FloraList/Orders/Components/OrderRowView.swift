//
//  OrderRowView.swift
//  FloraList
//
//  Created by User on 6/3/25.
//

import SwiftUI
import Networking

struct OrderRowView: View {
    let order: Order
    let customer: Customer?

    var body: some View {
        HStack(spacing: 12) {
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
                    }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text(order.description)
                    .font(.body)
                    .fontWeight(.medium)

                if let customer = customer {
                    Text(customer.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    statusIndicator
                    Spacer()
                    Text("$\(order.price, specifier: "%.0f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var statusIndicator: some View {
        Text(order.status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor.opacity(0.15), in: Capsule())
    }

    private var statusColor: Color {
        switch order.status {
        case .new: return .blue
        case .pending: return .orange
        case .delivered: return .green
        }
    }
}
