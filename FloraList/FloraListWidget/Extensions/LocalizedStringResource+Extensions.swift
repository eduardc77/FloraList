import Foundation

extension LocalizedStringResource {

    // MARK: - Widget Content
    static let revenue = LocalizedStringResource("revenue")
    static let totalOrders = LocalizedStringResource("total_orders")
    
    // MARK: - Interpolation Methods
    static func revenueNextFormat(_ next: String) -> LocalizedStringResource {
        LocalizedStringResource("revenue_next_format", defaultValue: "Next: \(next)")
    }
} 
