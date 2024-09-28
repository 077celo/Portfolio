//
//  MapView.swift
//  Quake Tracker
//
//  Created by Marcelo on 09/09/24.
//

// IMPORTANT NOTE: THE EARTHQUAKE PROPAGATION RADIUS AND MAP LOCATION IS NOT CURRENTLY WORKING BECAUSE THE FORMULA TO CALCULATE ITS LOCATION AND RANGE HAS CHANGED. THE NEW API PROVIDES DIFFERENT VALUE NAMES THAT NEEDS TO BE ADAPTED TO THE OLD FORMULA.

// THE OLD FORMULA FOR REFERENCE:
// let radius = 100 * pow(10, (lastQuake.magnitude - 3.0)) * 10 />>/ This formula gives the radius in meters
// let circleOverlay = MKCircle(center: epicenter, radius: radius)
// uiView.addOverlay(circleOverlay)


import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var data: EarthquakeData // Earthquake data model
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Ensure the user location is valid before setting the region
        if let location = uiView.userLocation.location {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            uiView.setRegion(region, animated: true)
        }

        // Ensure the last earthquake has valid latitude and longitude
        if let lastQuake = data.earthquakes.last,
           lastQuake.latitude != 0 && lastQuake.longitude != 0 {  // Only proceed with valid coordinates
            let epicenter = CLLocationCoordinate2D(latitude: lastQuake.latitude, longitude: lastQuake.longitude)

            // Set region to center on the earthquake epicenter
            let region = MKCoordinateRegion(
                center: epicenter,
                span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            )
            uiView.setRegion(region, animated: true)

            // Add a red dot annotation for the epicenter
            let annotation = MKPointAnnotation()
            annotation.coordinate = epicenter
            annotation.title = "Epicenter"
            uiView.addAnnotation(annotation)

            // Add a yellow circle overlay for the estimated radius
            let radius = 100 * pow(10, (lastQuake.magnitude - 3.0)) * 10 // Radius in meters
            let circleOverlay = MKCircle(center: epicenter, radius: radius)
            uiView.addOverlay(circleOverlay)
        } else {
            // Log or handle the case where the earthquake data is invalid
            print("Invalid or missing earthquake coordinates")
        }
    }

    // Adding the circle overlay and setting its color
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let circleRenderer = MKCircleRenderer(circle: circleOverlay)
                circleRenderer.strokeColor = .yellow
                circleRenderer.fillColor = UIColor.yellow.withAlphaComponent(0.15) // 15% opacity
                circleRenderer.lineWidth = 2
                return circleRenderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKPointAnnotation {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "epicenter") as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "epicenter")
                
                annotationView.markerTintColor = UIColor.red.withAlphaComponent(0.8) // 80% opacity red dot
                annotationView.glyphText = "🌍" // Optional icon
                return annotationView
            }
            return nil
        }
    }
}

struct MapViewContainer: View {
    @ObservedObject var data = EarthquakeData() // This should be passed down from the parent
    
    var body: some View {
        MapView(data: data)
            .frame(height: 300)
            .cornerRadius(10)
            .onAppear {
                data.fetchEarthquakeData() // Fetch data when the view appears
            }
    }
}
