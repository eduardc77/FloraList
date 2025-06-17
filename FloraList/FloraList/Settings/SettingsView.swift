//
//  SettingsView.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import SwiftUI
import FloraListNetwork

struct SettingsView: View {
    @Environment(LocationManager.self) private var locationManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(AnalyticsManager.self) private var analytics
    @Environment(OrderManager.self) private var orderManager

    var body: some View {
        NavigationView {
            SettingsContentView(
                viewModel: SettingsViewModel(
                    locationManager: locationManager,
                    notificationManager: notificationManager,
                    analyticsManager: analytics,
                    orderManager: orderManager
                )
            )
        }
    }
}

private struct SettingsContentView: View {
    @State private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
            List {
                Section {
                    locationRow
                    notificationRow
                } header: {
                    Text("Permissions")
                } footer: {
                    Text("Tap any permission to change it in Settings.")
                }
                
                Section {
                    networkingRow
                } header: {
                    Text("Developer")
                } footer: {
                    Text("Switch between REST and GraphQL networking implementations.")
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.onAppear()
            }
            .alert("Location Permission", isPresented: $viewModel.showingLocationAlert) {
                Button("Open Settings") {
                    viewModel.openAppSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.locationAlertMessage)
            }
            .alert("Notification Permission", isPresented: $viewModel.showingNotificationAlert) {
                Button("Open Settings") {
                    viewModel.openAppSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.notificationAlertMessage)
            }
    }

    // MARK: - Subviews

    private var locationRow: some View {
        Button {
            viewModel.showLocationAlert()
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
                    Text(viewModel.locationStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: viewModel.isLocationEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(viewModel.isLocationEnabled ? .green : .red)
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
            viewModel.showNotificationAlert()
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
                    Text(viewModel.notificationStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: viewModel.isNotificationEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(viewModel.isNotificationEnabled ? .green : .red)
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

    private var networkingRow: some View {
        Picker("API Implementation", selection: Binding(
            get: { viewModel.currentNetworkingType },
            set: { newType in
                viewModel.switchNetworkingType(to: newType)
            }
        )) {
            Text("REST").tag(NetworkingType.rest)
            Text("GraphQL").tag(NetworkingType.graphQL)
        }
        .pickerStyle(.menu)
    }
}

#Preview {
    SettingsView()
        .environment(LocationManager())
        .environment(NotificationManager())
        .environment(AnalyticsManager.shared)
        .environment(OrderManager(notificationManager: NotificationManager()))
}
