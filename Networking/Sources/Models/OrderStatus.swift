//
//  OrderStatus.swift
//  Networking
//
//  Created by User on 6/3/25.
//

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
}
