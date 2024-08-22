import Foundation
import SwiftUI
import CoreLocation
import CoreMotion

public struct SDKUIView: View {
    @State private var gpsData: String = "No GPS Data"
    @State private var barometerData: String = "No Barometer Data"
    
    private var locationManager = CLLocationManager()
    private var altimeter = CMAltimeter()
    
    public var onClose: (() -> Void)?
    
    public init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
        setupLocationManager()
    }
        
    public var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 20) {
                    Button(action: gpsAction) {
                        Text("GPS")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 150)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: barometerAction) {
                        Text("Barometer")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 150)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                
                Spacer()
                
                VStack {
                    Text(gpsData)
                        .font(.title)
                        .padding()
                    
                    Text(barometerData)
                        .font(.title)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    closeAction()
                    onClose?()
                }) {
                    Text("Close")
                        .foregroundColor(.black)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 150)
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(8)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = makeCoordinator()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func gpsAction() {
        locationManager.requestLocation()
    }
    
    private func barometerAction() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            barometerData = "Barometer not available"
            return
        }
        altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
            if let altitudeData = data {
                let pressure = altitudeData.pressure.doubleValue
                barometerData = "Pressure: \(pressure) kPa"
            }
            if let error = error {
                barometerData = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func closeAction() {
        altimeter.stopRelativeAltitudeUpdates()
        print("Close tapped")
    }
}

public extension SDKUIView {
    class Coordinator: NSObject, CLLocationManagerDelegate {
        var parent: SDKUIView
        
        init(parent: SDKUIView) {
            self.parent = parent
        }
        
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                parent.gpsData = "Lat: \(lat), Lon: \(lon)"
            }
        }
        
        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            parent.gpsData = "Failed to get location: \(error.localizedDescription)"
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}


