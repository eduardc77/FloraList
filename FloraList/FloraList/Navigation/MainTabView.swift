//
//  MainTabView.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .orders
    @Environment(NotificationManager.self) private var notificationManager

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                OrdersListView()
            }
            .tag(AppTab.orders)
            .tabItem {
                Label(AppTab.orders.title, systemImage: AppTab.orders.icon)
            }

            NavigationStack {
                Text("Map")
            }
            .tag(AppTab.map)
            .tabItem {
                Label(AppTab.map.title, systemImage: AppTab.map.icon)
            }

            NavigationStack {
                Text("Settings")
            }
            .tag(AppTab.settings)
            .tabItem {
                Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(NotificationManager())
}
