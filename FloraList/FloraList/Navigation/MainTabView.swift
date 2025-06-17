//
//  MainTabView.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            OrdersListView()
                .tag(AppTab.orders)
                .tabItem {
                    Label(AppTab.orders.title, systemImage: AppTab.orders.icon)
                }

            CustomerMapView()
                .tag(AppTab.map)
                .tabItem {
                    Label(AppTab.map.title, systemImage: AppTab.map.icon)
                }

            SettingsView()
                .tag(AppTab.settings)
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
        }
        .environment(\.selectedTab, $selectedTab)
    }
}

#Preview {
    @Previewable @State var selectedTab = AppTab.orders

    MainTabView(selectedTab: $selectedTab)
        .environment(OrderManager(notificationManager: NotificationManager()))
        .environment(NotificationManager())
}
