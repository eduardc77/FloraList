//
//  OrderStatus.swift
//  Networking
//
//  Created by User on 6/3/25.
//

import SwiftUI

public enum OrderStatus: String, CaseIterable, Codable, Sendable {
    case new
    case pending
    case delivered

    public var displayName: String {
        rawValue.capitalized
    }

    public var systemImage: String {
        switch self {
        case .new: return "plus.circle"
        case .pending: return "clock.circle"
        case .delivered: return "checkmark.circle"
        }
    }

    public var color: Color {
        switch self {
        case .new: return .blue
        case .pending: return .orange
        case .delivered: return .green
        }
    }
}
