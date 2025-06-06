//
//  SettingsView.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(LocationManager.self) private var locationManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(AnalyticsManager.self) private var analytics
    @Environment(OrderManager.self) private var orderManager
    @State private var showingLocationAlert = false
    @State private var showingNotificationAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var networkingTypeText: String {
        switch orderManager.networkingType {
        case .rest:
            return "REST"
        case .graphQL:
            return "GraphQL"
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    locationRow
                    notificationRow
                } header: {
                    Text("Permissions")
                } footer: {
                    Text("Tap any permission to change it in Settings.")
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Networking")
                        Spacer()
                        Text(networkingTypeText)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                analytics.trackScreenView(screenName: "Settings")
                // Refresh permission status when view appears
                Task {
                    await notificationManager.checkCurrentPermissionStatus()
                }
            }
        }
        .alert("Location Permission", isPresented: $showingLocationAlert) {
            Button("Open Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To \(locationManager.isLocationAvailable ? "disable" : "enable") location access, go to Settings > Privacy & Security > Location Services > FloraList.")
        }
        .alert("Notification Permission", isPresented: $showingNotificationAlert) {
            Button("Open Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To \(notificationManager.isPermissionGranted ? "disable" : "enable") notifications, go to Settings > Notifications > FloraList.")
        }
    }

    private var locationRow: some View {
        Button {
            showingLocationAlert = true
        } label: {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Location Services")
                        .foregroundStyle(.primary)
                    Text("Show distances and routes to customers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Read-only status indicator
                HStack(spacing: 6) {
                    Text(locationManager.isLocationAvailable ? "Enabled" : "Disabled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: locationManager.isLocationAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(locationManager.isLocationAvailable ? .green : .red)
                        .font(.caption)

                    // Chevron to indicate it's tappable
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var notificationRow: some View {
        Button {
            showingNotificationAlert = true
        } label: {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Notifications")
                        .foregroundStyle(.primary)
                    Text("Get updates when order status changes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Read-only status indicator
                HStack(spacing: 6) {
                    Text(notificationManager.isPermissionGranted ? "Enabled" : "Disabled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: notificationManager.isPermissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(notificationManager.isPermissionGranted ? .green : .red)
                        .font(.caption)

                    // Chevron to indicate it's tappable
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    SettingsView()
        .environment(LocationManager())
        .environment(NotificationManager())
        .environment(AnalyticsManager.shared)
        .environment(OrderManager(notificationManager: NotificationManager()))
}
