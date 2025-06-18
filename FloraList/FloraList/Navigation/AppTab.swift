//
//  AppTab.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI

enum AppTab: Hashable {
    case orders
    case map
    case settings

    var title: LocalizedStringResource {
        switch self {
        case .orders: .orders
        case .map: .map
        case .settings: .settings
        }
    }

    var icon: String {
        switch self {
        case .orders: "list.bullet"
        case .map: "map"
        case .settings: "gear"
        }
    }
}

// Environment key for selected tab
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<AppTab> = .constant(.orders)
}

extension EnvironmentValues {
    var selectedTab: Binding<AppTab> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
