//
//  LocationService.swift
//  WeatherAppDemo
//
//  Created by Davin Henrik on 5/15/23.
//

import Foundation
import CoreLocation

/// Define protocol -> declare single method that returns  a tuple w/ lat & long values.
protocol LocationServiceProtocol {
    func getLocation() -> (lat: Double, lon: Double)?
}

// Class inherits NSObject and delegates CLLocationManager
class LocationService: NSObject  {
    
    // manager; instance for managing/retrieving location specific info.
    private var manager: CLLocationManager = CLLocationManager()
    private var locationPoint: CLLocation?

    
    /*
     LocationService set as delegate(CLLocationManager), requesting updates.
     Check authorization status; if auth -> request user location.
     */
    override init() {
        super.init()
        manager.delegate = self
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            print("Permission not determined")
        }
        manager.startUpdatingLocation()
    }
}


// Extend functionality with additional protocol methods.
extension LocationService: CLLocationManagerDelegate {
    /* didUpdateLoca... called when LocationManager location values update.
     locationPoint is updated with this value.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else { return }
        locationPoint = userLocation
    }
    /*
     didChangeAuth... called when Auth status changes.
     if "authorizedWhenInUse" status; locationManager requested to fetch user location.
     */
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                manager.requestLocation()
            }
        }
    
    // didFail... called when error on location retrieval.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}


// Implement getLocation method.
// returns lat/long values if locationPoint != nil. 
extension LocationService: LocationServiceProtocol {
    func getLocation() -> (lat: Double, lon: Double)? {
        if let position = locationPoint {
            return (position.coordinate.latitude, position.coordinate.longitude)
        } else {
            return nil
        }
    }
}

