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
        NavigationStack {
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
                    Text(.permissions)
                } footer: {
                    Text(.permissionsDescription)
                }
                
                Section {
                    languagePicker
                } header: {
                    Text(.language)
                } footer: {
                    Text(.languageDescription)
                }
                
                Section {
                    networkingRow
                } header: {
                    Text(.developer)
                } footer: {
                    Text(.developerSettingsDescription)
                }
                
                Section {
                    HStack {
                        Text(.version)
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(.about)
                }
            }
            .listSectionSpacing(16)
            .contentMargins(.top, 16, for: .scrollContent)
            .navigationTitle(Text(.settings))
            .onAppear {
                viewModel.onAppear()
            }
            .alert(Text(.locationPermission), isPresented: $viewModel.showingLocationAlert) {
                Button {
                    viewModel.openAppSettings()
                } label: {
                    Text(.openSettings)
                }
                Button(role: .cancel) {
                    // Do nothing
                } label: {
                    Text(.cancel)
                }
            } message: {
                Text(viewModel.locationAlertMessage)
            }
            .alert(Text(.notificationPermission), isPresented: $viewModel.showingNotificationAlert) {
                Button {
                    viewModel.openAppSettings()
                } label: {
                    Text(.openSettings)
                }
                Button(role: .cancel) {
                    // Do nothing
                } label: {
                    Text(.cancel)
                }
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
                    Text(.locationServices)
                        .foregroundStyle(.primary)
                    Text(.locationServicesDescription)
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
                    Text(.notifications)
                        .foregroundStyle(.primary)
                    Text(.notificationsDescription)
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
        Picker(selection: Binding(
            get: { viewModel.currentNetworkingType },
            set: { newType in
                viewModel.switchNetworkingType(to: newType)
            }
        ), content: {
            Text(.rest).tag(NetworkingType.rest)
            Text(.graphql).tag(NetworkingType.graphQL)
        }, label: {
            Text(.apiImplementation)
        })
        .pickerStyle(.menu)
    }
    
    private var languagePicker: some View {
        Picker(selection: Binding(
            get: { LocalizationManager.shared.currentLanguage },
            set: { newLanguage in
                LocalizationManager.shared.setLanguage(newLanguage)
            }
        ), content: {
            ForEach(LocalizationManager.SupportedLanguage.allCases, id: \.self) { language in
                Group {
                    Text(language.flag) + Text(language.displayName)
                }
                .tag(language)
            }
        }, label: {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.purple)
                    .frame(width: 20)
                Text(.language)
            }
        })
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
