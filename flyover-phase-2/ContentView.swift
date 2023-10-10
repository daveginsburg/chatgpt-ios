//
//  ContentView.swift
//  test map project
//
//  Created by David Ginsburg on 7/27/23.
//
import SwiftUI
import CoreLocation

struct ContentView: View {
    // MARK: - State Properties
    @State private var addresses: [String]
    @State private var coordinates: [CLLocationCoordinate2D] = []
    @State private var altitude: CLLocationDistance = 3000 // default altitude
    @State private var duration: TimeInterval = 120.0 // default duration
    @State private var showAddressInput: Bool = true
    @State private var shouldStartFlyover: Bool = false
    @State private var flyoverCompleted: Bool = false

    // MARK: - Initialization
    init() {
        let savedAddresses = UserDefaults.standard.array(forKey: "addresses") as? [String] ?? ["", ""]
        _addresses = State(initialValue: savedAddresses)
    }

    // MARK: - Main Body
    var body: some View {
        VStack {
            // MapView and Flyover Completion Logic
            MapView(coordinates: $coordinates, altitude: $altitude, duration: $duration, shouldStartFlyover: $shouldStartFlyover) {
                withAnimation {
                    self.flyoverCompleted = true
                }
            }
            .onTapGesture {
                handleTapOnMap()
            }
            
            // Address Input UI
            if showAddressInput {
                addressInputView()
            }
        }
    }
    
    // MARK: - Subviews
    func addressInputView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                addressFields()
                flyoverControls()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
    }
    
    func addressFields() -> some View {
        VStack(spacing: 20) {
            ForEach(addresses.indices, id: \.self) { index in
                TextField("Address \(index + 1)", text: $addresses[index])
                    .padding(.horizontal)
                Divider()
            }
            Button("Add another address") {
                addresses.append("")
            }
            .padding(.horizontal)
            
            Button("Start Flyover") {
                startFlyover()
            }
            .padding(.horizontal)
        }
    }
    
    func flyoverControls() -> some View {
        VStack(spacing: 20) {
            VStack {
                Text("Altitude: \(altitude, specifier: "%.0f") meters")
                Slider(value: $altitude, in: 500...20000, step: 500)
            }
            .padding(.horizontal)
            
            VStack {
                Text("Duration: \(duration, specifier: "%.0f") seconds")
                Slider(value: $duration, in: 10...300, step: 10)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Actions
    func handleTapOnMap() {
        if flyoverCompleted {
            withAnimation {
                showAddressInput.toggle()
                shouldStartFlyover = false
                flyoverCompleted = false
            }
        }
    }
    
    func startFlyover() {
        coordinates.removeAll()
        geocodeNextAddress(at: 0)
        UserDefaults.standard.setValue(self.addresses, forKey: "addresses")
        withAnimation {
            showAddressInput.toggle()
        }
    }
    
    // MARK: - Geocoding
    func geocodeNextAddress(at index: Int) {
        guard index < addresses.count else {
            shouldStartFlyover = true
            withAnimation {
                showAddressInput = false
            }
            return
        }
        geocode(address: addresses[index]) { location in
            if let loc = location {
                coordinates.append(loc)
            }
            geocodeNextAddress(at: index + 1)
        }
    }

    func geocode(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let err = error {
                print("Error geocoding address: \(address). Error: \(err.localizedDescription)")
                completion(nil)
                return
            }
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(coordinate)
        }
    }
}

