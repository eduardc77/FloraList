//
//  FloraListApp.swift
//  FloraList
//
//  Created by User on 6/2/25.
//

import SwiftUI

@main
struct FloraListApp: App {
    @State private var orderManager = OrderManager()
    @State private var coordinator = OrdersCoordinator()
    @State private var deepLinkManager = DeepLinkManager()
    @State private var errorMessage: String?
    @State private var notificationManager = NotificationManager()
    @State private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(orderManager)
                .environment(coordinator)
                .environment(notificationManager)
                .environment(locationManager)
                .task {
                    deepLinkManager.setup(with: orderManager, coordinator: coordinator)
                    await notificationManager.setup()
                    locationManager.requestLocationPermission()
                    // Initial data fetch
                    await orderManager.fetchData()
                }
                .onOpenURL { url in
                    Task {
                        do {
                            try await deepLinkManager.handle(url)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .alert("Deep Link Error",
                       isPresented: .init(
                        get: { errorMessage != nil },
                        set: { if !$0 { errorMessage = nil } }
                       )) {
                    Button("OK") {
                        errorMessage = nil
                    }
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
        }
    }
}
