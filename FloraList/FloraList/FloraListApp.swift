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
    @State private var locationManager = LocationManager()
    @State private var routeManager: RouteManager
    @State private var analyticsManager = AnalyticsManager.shared
    @State private var localizationManager = LocalizationManager.shared

    @State private var deepLinkErrorMessage: String?

    init() {
        let notificationManager = NotificationManager()
        let locationManager = LocationManager()
        self._notificationManager = State(initialValue: notificationManager)
        self._locationManager = State(initialValue: locationManager)
        self._orderManager = State(initialValue: OrderManager(notificationManager: notificationManager))
        self._routeManager = State(initialValue: RouteManager(locationManager: locationManager))
        configureFirebase()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(orderManager)
                .environment(coordinator)
                .environment(mapCoordinator)
                .environment(notificationManager)
                .environment(locationManager)
                .environment(routeManager)
                .environment(deepLinkManager)
                .environment(analyticsManager)
                .environment(localizationManager)
                .environment(\.locale, localizationManager.currentLanguage.locale)
                .task {
                    await notificationManager.setup()
                    locationManager.requestLocationPermission()
                }
                .onOpenURL { url in
                    Task {
                        do {
                            try await deepLinkManager.handle(url)
                        } catch {
                            deepLinkErrorMessage = error.localizedDescription
                        }
                    }
                }
                .alert(Text(.deepLinkError),
                       isPresented: .init(
                        get: { deepLinkErrorMessage != nil },
                        set: { if !$0 { deepLinkErrorMessage = nil } }
                       )) {
                    Button {
                        deepLinkErrorMessage = nil
                    } label: {
                        Text(.ok)
                    }
                } message: {
                    if let deepLinkErrorMessage {
                        Text(deepLinkErrorMessage)
                    }
                }
        }
    }

    private func configureFirebase() {
        FirebaseApp.configure()

        // Set Firebase log level to warning or error only
        #if !DEBUG
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        #endif
    }
}
