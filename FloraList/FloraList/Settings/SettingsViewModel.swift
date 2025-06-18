//
//  SettingsViewModel.swift
//  FloraList
//
//  Created by User on 6/8/25.
//

import SwiftUI
import FloraListNetwork

@MainActor
@Observable
class SettingsViewModel {
    private let locationManager: LocationManager
    private let notificationManager: NotificationManager
    private let analyticsManager: AnalyticsManager
    private let orderManager: OrderManager
    private let localizationManager: LocalizationManager

    var showingLocationAlert = false
    var showingNotificationAlert = false
    var currentLanguage: LocalizationManager.SupportedLanguage {
        get { localizationManager.currentLanguage }
        set { localizationManager.setLanguage(newValue) }
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var networkingTypeText: LocalizedStringResource {
        switch orderManager.networkingType {
        case .rest:
            return .rest
        case .graphQL:
            return .graphql
        }
    }
    
    var isLocationEnabled: Bool {
        locationManager.isLocationAvailable
    }
    
    var isNotificationEnabled: Bool {
        notificationManager.isPermissionGranted
    }
    
    var currentNetworkingType: NetworkingType {
        orderManager.networkingType
    }
    
    var locationStatusText: LocalizedStringResource {
        isLocationEnabled ? .enabled : .disabled
    }
    
    var notificationStatusText: LocalizedStringResource {
        isNotificationEnabled ? .enabled : .disabled
    }
    
    var locationAlertMessage: String {
        "To \(isLocationEnabled ? "disable" : "enable") location access, go to Settings > Privacy & Security > Location Services > FloraList."
    }
    
    var notificationAlertMessage: String {
        "To \(isNotificationEnabled ? "disable" : "enable") notifications, go to Settings > Notifications > FloraList."
    }

    init(
        locationManager: LocationManager,
        notificationManager: NotificationManager,
        analyticsManager: AnalyticsManager,
        orderManager: OrderManager,
        localizationManager: LocalizationManager = .shared
    ) {
        self.locationManager = locationManager
        self.notificationManager = notificationManager
        self.analyticsManager = analyticsManager
        self.orderManager = orderManager
        self.localizationManager = localizationManager
    }
    
    // MARK: - Methods

    func onAppear() {
        analyticsManager.trackScreenView(screenName: "Settings")
        Task {
            await refreshNotificationPermissionStatus()
        }
    }
    
    func showLocationAlert() {
        showingLocationAlert = true
    }
    
    func showNotificationAlert() {
        showingNotificationAlert = true
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func switchNetworkingType(to newType: NetworkingType) {
        Task {
            await orderManager.switchToNetworkingType(newType)
        }
    }
    
    private func refreshNotificationPermissionStatus() async {
        await notificationManager.checkCurrentPermissionStatus()
    }
}
