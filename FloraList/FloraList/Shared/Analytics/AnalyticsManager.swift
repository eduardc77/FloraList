//
//  AnalyticsManager.swift
//  FloraList
//
//  Created by User on 6/5/25.
//

import Observation
import FirebaseAnalytics

@Observable
final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    func trackScreenView(screenName: String, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
    }

    func trackOrderStatusUpdate(orderId: Int, oldStatus: String, newStatus: String) {
        Analytics.logEvent("order_status_updated", parameters: [
            "order_id": orderId,
            "old_status": oldStatus,
            "new_status": newStatus
        ])
    }
}
