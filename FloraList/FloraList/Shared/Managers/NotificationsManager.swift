//
//  NotificationsManager.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import UserNotifications

@Observable
final class NotificationManager {
    private let center = UNUserNotificationCenter.current()
    private(set) var isPermissionGranted = false

    init() {
        center.delegate = NotificationHandler.shared
    }

    func setup() async {
        await checkCurrentPermissionStatus()

        if !isPermissionGranted {
            let granted = (try? await requestPermission()) ?? false
            await updatePermissionStatus(granted)
        }
    }

    func requestPermission() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        await updatePermissionStatus(granted)
        return granted
    }

    func updatePermissionStatus(_ granted: Bool) async {
        isPermissionGranted = granted
    }

    func checkCurrentPermissionStatus() async {
        let settings = await center.notificationSettings()
        isPermissionGranted = settings.authorizationStatus == .authorized
    }

    func scheduleOrderStatusNotification(orderId: Int, description: String, status: String) async throws {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            throw NSError(
                domain: "NotificationManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Notification permission not granted"]
            )
        }

        let content = UNMutableNotificationContent()
        content.title = "Order Status Updated"
        content.body = "Order #\(orderId) (\(description)) is now \(status)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "order-\(orderId)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }
}

// MARK: - Notification Handler

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show banner, play sound, and add to notifications list
        return [.banner, .sound, .list]
    }
}
