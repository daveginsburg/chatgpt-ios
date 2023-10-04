//
//  MapView.swift
//  test map project
//
//  Created by David Ginsburg on 7/27/23.
//

import SwiftUI
import MapKit





struct MapView: UIViewRepresentable {
    @Binding var pinLocation: CLLocationCoordinate2D?
    @Binding var pinTitle: String
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .satelliteFlyover  // Use satelliteFlyover for 3D buildings and terrain
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        if let pinLocation = self.pinLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pinLocation
            annotation.title = pinTitle
            uiView.addAnnotation(annotation)
            
            // Set up the 3D camera
            let distance: CLLocationDistance = 200 // Distance from the target, adjust this value as needed
            let pitch: CGFloat = 70 // Tilt of the camera, adjust to get the 3D effect you want
            let offset = 0.00 // This value will determine how much to offset. Adjust as needed.
                    let newCenter = CLLocationCoordinate2D(latitude: pinLocation.latitude - offset, longitude: pinLocation.longitude - offset) // Shifts the center north and west. Adjust based on the desired direction.
                    let camera = MKMapCamera(lookingAtCenter: newCenter, fromDistance: distance, pitch: pitch, heading: 0)
                   
            
            uiView.setCamera(camera, animated: true)
        }
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "location"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}


