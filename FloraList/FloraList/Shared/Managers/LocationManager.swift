//
//  LocationManager.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import Foundation
import CoreLocation
import Networking
import MapKit

@Observable
final class LocationManager: NSObject {
    private let locationManager = CLLocationManager()

    private static let distanceFormatter: MKDistanceFormatter = {
        let formatter = MKDistanceFormatter()
        formatter.units = .metric
        return formatter
    }()

    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var isLocationAvailable: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }

    private func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }

        locationManager.startUpdatingLocation()
    }

    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Distance Calculations

    func distance(to customer: Customer) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }

        let customerLocation = CLLocation(
            latitude: customer.latitude,
            longitude: customer.longitude
        )

        return currentLocation.distance(from: customerLocation)
    }

    func formattedDistance(to customer: Customer) -> String {
        guard let distance = distance(to: customer) else {
            return "Distance unavailable"
        }

        return LocationManager.distanceFormatter.string(fromDistance: distance)
    }

    // MARK: - Route Calculations
    
    func calculateRoute(to customer: Customer) async throws -> MKRoute? {
        guard let currentLocation = currentLocation else { return nil }
        
        let sourcePlacemark = MKPlacemark(coordinate: currentLocation.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: customer.latitude, longitude: customer.longitude))
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            let route = response.routes.first
            directions.cancel()
            
            return route
        } catch {
            directions.cancel()
            throw error
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        isLocationAvailable = true

        // Stop continuous updates to save battery
        // We only need periodic updates for distance calculations
        stopLocationUpdates()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        isLocationAvailable = false
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAvailable = true
            startLocationUpdates()
        case .denied, .restricted:
            isLocationAvailable = false
            stopLocationUpdates()
        case .notDetermined:
            isLocationAvailable = false
        @unknown default:
            isLocationAvailable = false
        }
    }
}
