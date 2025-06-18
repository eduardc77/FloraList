import Foundation

extension LocalizedStringResource {

    // MARK: - Navigation & Tabs
    static let orders = LocalizedStringResource("orders")
    static let map = LocalizedStringResource("map")
    static let settings = LocalizedStringResource("settings")
    static let customerLocations = LocalizedStringResource("customer_locations")
    static let customerDetails = LocalizedStringResource("customer_details")
    
    // MARK: - Common Actions
    static let cancel = LocalizedStringResource("cancel")
    static let tryAgain = LocalizedStringResource("try_again")
    static let openSettings = LocalizedStringResource("open_settings")
    static let clearAll = LocalizedStringResource("clear_all")
    static let filter = LocalizedStringResource("filter")
    static let done = LocalizedStringResource("done")
    static let viewOnMap = LocalizedStringResource("view_on_map")
    static let ok = LocalizedStringResource("ok")
    static let deepLinkError = LocalizedStringResource("deep_link_error")
    
    // MARK: - Settings
    static let permissions = LocalizedStringResource("permissions")
    static let permissionsDescription = LocalizedStringResource("permissions_description")
    static let developer = LocalizedStringResource("developer")
    static let developerSettingsDescription = LocalizedStringResource("developer_settings_description")
    static let about = LocalizedStringResource("about")
    static let version = LocalizedStringResource("version")
    
    // MARK: - Location Services
    static let locationServices = LocalizedStringResource("location_services")
    static let locationServicesDescription = LocalizedStringResource("location_services_description")
    static let locationPermission = LocalizedStringResource("location_permission")
    static let enabled = LocalizedStringResource("enabled")
    static let disabled = LocalizedStringResource("disabled")
    
    // MARK: - Notifications
    static let notifications = LocalizedStringResource("notifications")
    static let notificationsDescription = LocalizedStringResource("notifications_description")
    static let notificationPermission = LocalizedStringResource("notification_permission")
    
    // MARK: - API Implementation
    static let apiImplementation = LocalizedStringResource("api_implementation")
    static let rest = LocalizedStringResource("rest")
    static let graphql = LocalizedStringResource("graphql")
    
    // MARK: - Order Status
    static let orderStatusNew = LocalizedStringResource("order_status_new")
    static let orderStatusPending = LocalizedStringResource("order_status_pending")
    static let orderStatusDelivered = LocalizedStringResource("order_status_delivered")
    
    // MARK: - Sorting & Filtering
    static let sortOrders = LocalizedStringResource("sort_orders")
    static let filterByStatus = LocalizedStringResource("filter_by_status")
    static let sortPriceHighToLow = LocalizedStringResource("sort_price_high_to_low")
    static let sortPriceLowToHigh = LocalizedStringResource("sort_price_low_to_high")
    static let sortStatus = LocalizedStringResource("sort_status")
    
    // MARK: - Search & Loading
    static let searchOrders = LocalizedStringResource("search_orders")
    static let loadingOrders = LocalizedStringResource("loading_orders")
    static let loadingCustomerLocations = LocalizedStringResource("loading_customer_locations")
    static let calculatingDistance = LocalizedStringResource("calculating_distance")
    
    // MARK: - Error Messages
    static let unableToLoadOrders = LocalizedStringResource("unable_to_load_orders")
    static let unableToLoadLocations = LocalizedStringResource("unable_to_load_locations")
    static let distanceUnavailable = LocalizedStringResource("distance_unavailable")
    static let enableLocationForDistance = LocalizedStringResource("enable_location_for_distance")
    static let customerInformationUnavailable = LocalizedStringResource("customer_information_unavailable")
    static let noOrdersYet = LocalizedStringResource("no_orders_yet")
    static let customerNoOrdersMessage = LocalizedStringResource("customer_no_orders_message")

    // MARK: - Notifications Content
    static let orderStatusUpdated = LocalizedStringResource("order_status_updated")
    
    // MARK: - Interpolation Methods
    static func orderIdFormat(_ id: String) -> LocalizedStringResource {
        LocalizedStringResource("order_id_format", defaultValue: "Order #\(id)")
    }
    
    static func customerIdFormat(_ id: String) -> LocalizedStringResource {
        LocalizedStringResource("customer_id_format", defaultValue: "Customer ID: \(id)")
    }
    
    static func latitudeLongitudeFormat(_ latitude: String, _ longitude: String) -> LocalizedStringResource {
        LocalizedStringResource("latitude_longitude_format", defaultValue: "Lat: \(latitude), Lon: \(longitude)")
    }
  
    static func orderStatusUpdatedBody(_ orderId: String, _ description: String, _ status: String) -> LocalizedStringResource {
        LocalizedStringResource("order_status_updated_body", defaultValue: "Order #\(orderId) (\(description)) is now \(status)")
    }
    
    static func ordersWithCount(_ count: Int) -> LocalizedStringResource {
        LocalizedStringResource("orders_with_count", defaultValue: "Orders (\(count))")
    }
    
    // MARK: - Language Settings
    static let language = LocalizedStringResource("language", comment: "Language settings section header")
    static let languageDescription = LocalizedStringResource("language_description", comment: "Language settings description")
    static let english = LocalizedStringResource("english", comment: "English language option")
    static let spanish = LocalizedStringResource("spanish", comment: "Spanish language option")
    static let german = LocalizedStringResource("german", comment: "German language option")
} 
