//
//  AppTab.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

enum AppTab: Hashable {
    case orders
    case map
    case settings

    var title: String {
        switch self {
        case .orders: "Orders"
        case .map: "Map"
        case .settings: "Settings"
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
