//
//  ContentView.swift
//  FloraList
//
//  Created by User on 6/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: AppTab = .orders
    @Environment(OrderManager.self) private var orderManager
    @Environment(OrdersCoordinator.self) private var coordinator
    @Environment(CustomerMapCoordinator.self) private var mapCoordinator
    @Environment(DeepLinkManager.self) private var deepLinkManager

    var body: some View {
        MainTabView(selectedTab: $selection)
            .task {
                // Setup deep link manager with access to selection
                deepLinkManager.setup(
                    with: orderManager,
                    coordinator: coordinator,
                    mapCoordinator: mapCoordinator,
                    selectedTab: $selection
                )
            }
    }
}

#Preview {
    ContentView()
        .environment(OrderManager())
        .environment(OrdersCoordinator())
        .environment(CustomerMapCoordinator())
        .environment(DeepLinkManager())
        .environment(NotificationManager())
        .environment(LocationManager())
}
