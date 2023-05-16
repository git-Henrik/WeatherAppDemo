//
//  LocationManager.swift
//  WeatherAppDemo
//
//  Created by Davin Henrik on 5/15/23.
//

// Manage CLLocationManager from CoreLocation

import Foundation
import CoreLocation

// Cannot be subclassed.
/* Protocols:
    NSObject; interoperability w/ Obj-C
    ObservableObject; SwiftUI data binding
    CLLocation...; handling location events
 */
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var lastSearchedCity = ""

    var foundLandmark:Bool = false

    // Check if location services enabled on device.
    func checkIfLocationServicesIsEnabled(){
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled(){
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest/// kCLLocationAccuracyBest is the default
                self.checkLocationAuthorization()
            }else{
                print("Location manager not loaded")
            }
        }
    }

    // Directs action based on Auth status.
    private func checkLocationAuthorization(){
        switch locationManager.authorizationStatus{
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    // Called when Auth status changes.
    // checkLocationAuthorization() handles the updates.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    // Called when new location updates are available.
    // foundlandmark = false; not found yet
    // GLGeocoder; reverse geocode the location and obtain assoc. landmarks.
    // if found; extract city and set to lastSearchedCity.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        foundLandmark = false

        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
            if error != nil {
                self.locationManager.stopUpdatingLocation()
                // show error message
            }
            if placemarks!.count > 0 {
                if !self.foundLandmark{
                    self.foundLandmark = true
                    let placemark = placemarks![0]

                    self.lastSearchedCity = placemark.locality ?? ""
                }
                self.locationManager.stopUpdatingLocation()
            }else{
                // no places found
            }
        })
    }
    
    // Print any errors during location retrieval. 
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

