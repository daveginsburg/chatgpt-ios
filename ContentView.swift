//
//  ContentView.swift
//  test map project
//
//  Created by David Ginsburg on 7/27/23.
//

import SwiftUI
import CoreLocation



 struct ContentView: View {
    @State private var searchText = ""
    @State private var pinLocation: CLLocationCoordinate2D?
    @State private var pinTitle: String = ""
    
    var body: some View {
        VStack {
            MapView(pinLocation: $pinLocation, pinTitle: $pinTitle)
                .edgesIgnoringSafeArea(.top)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                TextField("Enter address...", text: $searchText, onCommit: {
                    geocodeAddress()
                })
                Button(action: geocodeAddress, label: {
                    Text("Submit")
                })
            }
            .padding()
        }
    }
    
    func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { (placemarks, error) in
            if let firstPlacemark = placemarks?.first, let location = firstPlacemark.location {
                pinLocation = location.coordinate
                pinTitle = [
                    firstPlacemark.subThoroughfare,
                    firstPlacemark.thoroughfare,
                    firstPlacemark.locality,
                    firstPlacemark.administrativeArea,
                    firstPlacemark.postalCode,
                    firstPlacemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }
}


