//
//  FloraListApp.swift
//  FloraList
//
//  Created by User on 6/2/25.
//

import SwiftUI
import FirebaseCore

@main
struct FloraListApp: App {
    @State private var notificationManager = NotificationManager()
    @State private var orderManager: OrderManager
    @State private var coordinator = OrdersCoordinator()
    @State private var mapCoordinator = CustomerMapCoordinator()
    @State private var deepLinkManager = DeepLinkManager()
    @State private var errorMessage: String?
    @State private var locationManager = LocationManager()
    @State private var analyticsManager = AnalyticsManager.shared

    init() {
        FirebaseApp.configure()
        let notificationManager = NotificationManager()
        self._notificationManager = State(initialValue: notificationManager)
        self._orderManager = State(initialValue: OrderManager(notificationManager: notificationManager))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(orderManager)
                .environment(coordinator)
                .environment(mapCoordinator)
                .environment(notificationManager)
                .environment(locationManager)
                .environment(deepLinkManager)
                .environment(analyticsManager)
                .task {
                    await notificationManager.setup()
                    locationManager.requestLocationPermission()
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
