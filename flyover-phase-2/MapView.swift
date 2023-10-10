//
//  MapView.swift
//  test map project
//
//  Created by David Ginsburg on 7/27/23.
//
import SwiftUI
import MapKit

// MARK: - MapView
/// SwiftUI view that wraps an `MKMapView` to show a flyover of a series of locations.
struct MapView: UIViewRepresentable {
    @Binding var coordinates: [CLLocationCoordinate2D]
    @Binding var altitude: CLLocationDistance
    @Binding var duration: TimeInterval
    @Binding var shouldStartFlyover: Bool
    
    var onFlyoverCompletion: (() -> Void)? = nil

    /// Creates the MKMapView for SwiftUI
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .satelliteFlyover
        return mapView
    }
    
    /// Updates the MKMapView whenever any of the bound properties change
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if coordinates.count >= 2 && shouldStartFlyover && !context.coordinator.isFlyoverActive {
            context.coordinator.isFlyoverActive = true
            startFlyoverSequence(mapView: uiView, locations: coordinates, duration: duration, altitude: altitude, completion: {
                onFlyoverCompletion?()
                DispatchQueue.main.async {
                    context.coordinator.isFlyoverActive = false
                }
            })
        }
    }
    
    /// Creates the Coordinator for this view
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    /// Coordinator class to handle `MKMapView` delegate methods
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var isFlyoverActive: Bool = false

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}

// MARK: - Flyover Animation
/// Initiates the flyover sequence animation on the provided mapView
func startFlyoverSequence(mapView: MKMapView, locations: [CLLocationCoordinate2D], duration: TimeInterval, altitude: CLLocationDistance, completion: @escaping () -> Void) {
    guard locations.count >= 2 else {
        completion()
        return
    }
    
    let startCoordinate = locations[0]
    let endCoordinate = locations[1]
    
    let startLocation = CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude)
    let endLocation = CLLocation(latitude: endCoordinate.latitude, longitude: endCoordinate.longitude)
    let initialHeading = startLocation.course(to: endLocation)

    let startingCamera = MKMapCamera(lookingAtCenter: startCoordinate, fromDistance: altitude, pitch: 75, heading: initialHeading)
    mapView.setCamera(startingCamera, animated: false)
    
    let intermediateCamera = MKMapCamera(lookingAtCenter: endCoordinate, fromDistance: altitude, pitch: 75, heading: initialHeading)

    UIView.animate(withDuration: duration * 0.75, animations: {
        mapView.camera = intermediateCamera
    }, completion: { _ in
        if locations.count > 2 {
            let nextCoordinate = locations[2]
            let nextLocation = CLLocation(latitude: nextCoordinate.latitude, longitude: nextCoordinate.longitude)
            let nextHeading = endLocation.course(to: nextLocation)
            
            let cameraHeadingToNextLocation = MKMapCamera(lookingAtCenter: endCoordinate, fromDistance: altitude, pitch: 75, heading: nextHeading)
            
            UIView.animate(withDuration: 5, animations: {
                mapView.camera = cameraHeadingToNextLocation
            }, completion: { _ in
                let remainingLocations = Array(locations.dropFirst())
                startFlyoverSequence(mapView: mapView, locations: remainingLocations, duration: duration, altitude: altitude, completion: completion)
            })
        } else {
            completion()
        }
    })
}

// MARK: - CLLocation Extension
/// Extension to calculate the direction from one location to another
extension CLLocation {
    func course(to destination: CLLocation) -> CLLocationDirection {
        let lat1 = self.coordinate.latitude.degreesToRadians
        let lon1 = self.coordinate.longitude.degreesToRadians

        let lat2 = destination.coordinate.latitude.degreesToRadians
        let lon2 = destination.coordinate.longitude.degreesToRadians

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let radiansBearing = atan2(y, x)

        return radiansBearing.radiansToDegrees
    }
}

// MARK: - Double Extension for Angle Conversion
/// Extension to convert between degrees and radians
extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
}



