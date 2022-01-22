//
//  ViewController.swift
//  Location Router
//
//  Created by Oksana Poliakova on 21.01.2022.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private lazy var latitude = locationManager.location?.coordinate.latitude
    private lazy var longitude = locationManager.location?.coordinate.latitude
    private var currentPlace: CLPlacemark?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
    }
    
    // MARK: - Setup location
    private func setupLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Location authorization status
    private func locationAuthorizationStatus() -> CLAuthorizationStatus {
        var locationAuthorizationStatus : CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus =  locationManager.authorizationStatus
        } else {
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        return locationAuthorizationStatus
    }

}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print("Location")
        }
        
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
//            guard let firstPlace = places.first
    }
    
    /// Requesting Location Authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return
        case .authorizedWhenInUse:
            return
        case .denied:
            return
        case .restricted:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestLocation()
        default:
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error location")
    }
}

