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
        // Remove existing annotations (except user location)
        uiView.removeAnnotations(uiView.annotations.filter { !($0 is MKUserLocation) })
        
        // Remove existing overlays
        uiView.removeOverlays(uiView.overlays)

        // Add customer annotations
        let annotations = customers.map { customer in
            CustomerAnnotation(customer: customer)
        }
        uiView.addAnnotations(annotations)
        
        // Add route overlays if enabled
        if showRoutes {
            let polylines = routes.map { $0.polyline }
            uiView.addOverlays(polylines)
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
            shouldCenterOnUser = false
            isCenteredOnUser = true
        }

        // Auto center on customers if no user location available
        if !customers.isEmpty && userLocation == nil {
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

            // Add detail disclosure button
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
                parent.isCenteredOnUser = false
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
