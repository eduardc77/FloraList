//
//  MapView.swift
//  FloraList
//
//  Created by User on 6/4/25.
//

import SwiftUI
import MapKit
import Networking

struct MapView: UIViewRepresentable {
    let customers: [Customer]
    @Binding var selectedCustomer: Customer?
    let userLocation: CLLocationCoordinate2D?
    @Binding var showRoutes: Bool
    let routes: [MKRoute]
    let routeManager: RouteManager
    let locationManager: LocationManager
    @Binding var shouldCenterOnUser: Bool
    @Binding var isCenteredOnUser: Bool

    private static let defaultLatitude: CLLocationDegrees = 46.7712
    private static let defaultLongitude: CLLocationDegrees = 23.6236
    private static let defaultCoordinate = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none

        // Set initial region - use user location if available, otherwise default
        let centerCoordinate = userLocation ?? Self.defaultCoordinate
        
        let initialRegion = MKCoordinateRegion(
            center: centerCoordinate,
            latitudinalMeters: 20000,
            longitudinalMeters: 20000
        )
        mapView.setRegion(initialRegion, animated: false)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.parent = self
        
        // Only update annotations if customers have changed
        let currentAnnotations = uiView.annotations.compactMap { $0 as? CustomerAnnotation }
        let currentCustomerIDs = Set(currentAnnotations.map { $0.customer.id })
        let newCustomerIDs = Set(customers.map { $0.id })
        
        if currentCustomerIDs != newCustomerIDs {
            // Remove annotations for customers that are no longer in the list
            let annotationsToRemove = currentAnnotations.filter { annotation in
                !newCustomerIDs.contains(annotation.customer.id)
            }
            if !annotationsToRemove.isEmpty {
                uiView.removeAnnotations(annotationsToRemove)
            }
            
            // Add annotations for new customers
            let newCustomers = customers.filter { customer in
                !currentCustomerIDs.contains(customer.id)
            }
            if !newCustomers.isEmpty {
                let newAnnotations = newCustomers.map { CustomerAnnotation(customer: $0) }
                uiView.addAnnotations(newAnnotations)
            }
        }
        
        // Update annotations based on route state changes
        for annotation in currentAnnotations {
            // Update route time for active routes only
            if routeManager.isRouteShown(for: annotation.customer) {
                if annotation.routeTimeText == nil,
                   let route = routeManager.currentRoute {
                    annotation.routeTimeText = RouteManager.formatTime(route.expectedTravelTime)
                    
                    // Update the annotation view to trigger smooth callout refresh
                    if let annotationView = uiView.view(for: annotation) {
                        annotationView.annotation = annotation
                    }
                }
            } else {
                // Clear route time if no active route line
                if annotation.routeTimeText != nil {
                    annotation.routeTimeText = nil
                    
                    // Update the annotation view to trigger smooth callout refresh
                    if let annotationView = uiView.view(for: annotation) {
                        annotationView.annotation = annotation
                    }
                }
            }
        }
        
        // Update overlays when routes change
        let currentOverlayCount = uiView.overlays.count
        let newRouteCount = showRoutes ? routes.count : 0
        
        // Check if we need to update overlays (different count or routes changed)
        let needsOverlayUpdate = currentOverlayCount != newRouteCount || 
                                (showRoutes && !routes.isEmpty && currentOverlayCount > 0)
        
        if needsOverlayUpdate {
            // Always remove existing overlays first
            if !uiView.overlays.isEmpty {
                uiView.removeOverlays(uiView.overlays)
            }
            
            // Add new routes if we should show them
            if showRoutes && !routes.isEmpty {
                let polylines = routes.map { $0.polyline }
                uiView.addOverlays(polylines)
            }
        }
        
        // Handle centering on user location
        if shouldCenterOnUser, let userLocation = userLocation {
            // Preserve current zoom level by keeping the same span
            let currentRegion = uiView.region
            let newRegion = MKCoordinateRegion(
                center: userLocation,
                span: currentRegion.span
            )
            uiView.setRegion(newRegion, animated: true)
            
            // Reset the trigger and mark as centered
            DispatchQueue.main.async {
                self.shouldCenterOnUser = false
                self.isCenteredOnUser = true
            }
        }

        // Auto center on customers if no user location available
        if !customers.isEmpty && userLocation == nil && currentAnnotations.isEmpty {
            let coordinates = customers.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }
            let region = coordinateRegion(for: coordinates)
            uiView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Helper Methods

    private func coordinateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: Self.defaultCoordinate,
                latitudinalMeters: 20000,
                longitudinalMeters: 20000
            )
        }

        let minLat = coordinates.map(\.latitude).min() ?? Self.defaultLatitude
        let maxLat = coordinates.map(\.latitude).max() ?? Self.defaultLatitude
        let minLon = coordinates.map(\.longitude).min() ?? Self.defaultLongitude
        let maxLon = coordinates.map(\.longitude).max() ?? Self.defaultLongitude

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.3,
            longitudeDelta: (maxLon - minLon) * 1.3
        )

        return MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Coordinator

extension MapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customerAnnotation = annotation as? CustomerAnnotation else {
                return nil
            }

            let identifier = "CustomerPin"
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            annotationView.annotation = customerAnnotation
            annotationView.canShowCallout = true
            annotationView.markerTintColor = .systemBlue
            annotationView.glyphText = "🌸"

            if parent.locationManager.isLocationAvailable {
                customerAnnotation.distanceText = parent.locationManager.formattedDistance(to: customerAnnotation.customer)
            }
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = detailButton

            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let customerAnnotation = view.annotation as? CustomerAnnotation else { return }
            parent.selectedCustomer = customerAnnotation.customer
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let customerAnnotation = view.annotation as? CustomerAnnotation else { return }
            parent.selectedCustomer = customerAnnotation.customer
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            // When user starts manually moving the map, we're no longer centered on user
            if parent.isCenteredOnUser {
                DispatchQueue.main.async {
                    self.parent.isCenteredOnUser = false
                }
            }
        }
        
        // MARK: - Overlay Delegate
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
