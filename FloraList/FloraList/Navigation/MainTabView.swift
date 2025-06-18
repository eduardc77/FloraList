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
                    Label {
                        Text(AppTab.orders.title)
                    } icon: {
                        Image(systemName: AppTab.orders.icon)
                    }
                }

            CustomerMapView()
                .tag(AppTab.map)
                .tabItem {
                    Label {
                        Text(AppTab.map.title)
                    } icon: {
                        Image(systemName: AppTab.map.icon)
                    }
                }

            SettingsView()
                .tag(AppTab.settings)
                .tabItem {
                    Label {
                        Text(AppTab.settings.title)
                    } icon: {
                        Image(systemName: AppTab.settings.icon)
                    }
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
