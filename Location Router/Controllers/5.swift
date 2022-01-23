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
    private let completer = MKLocalSearchCompleter()
    private let defaultAnimationDuration: TimeInterval = 0.25
    
    @IBOutlet weak var nameOfPlace: UITextField!
    @IBOutlet weak var stopAddress: UITextField!
    @IBOutlet weak var extraStopAddress: UITextField!
    @IBOutlet weak var suggestionContainerView: UIView!
    @IBOutlet weak var suggestionLabel: UILabel!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargetsForFields()
        setupLocation()
        completer.delegate = self
    }
    
    // MARK: - Setup location
    
    private func setupLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
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
    
    // MARK: - Targets for fields
    
    private func addTargetsForFields() {
        nameOfPlace.addTarget(self, action: #selector(changeNameOfPlace(_:)), for: .allEditingEvents)
        stopAddress.addTarget(self, action: #selector(changeStopAddress(_:)), for: .allEditingEvents)
        extraStopAddress.addTarget(self, action: #selector(changeExtraStopAddress(_:)), for: .allEditingEvents)
    }
    
    @objc private func changeNameOfPlace(_ sender: UITextField) {
        textFieldDidChange(sender)
    }
    
    @objc private func changeStopAddress(_ sender: UITextField) {
        textFieldDidChange(sender)
    }
    
    @objc private func changeExtraStopAddress(_ sender: UITextField) {
        textFieldDidChange(sender)
    }
    
    private func textFieldDidChange(_ field: UITextField) {
        if field == nameOfPlace && currentPlace != nil {
            currentPlace = nil
            field.text = ""
        }
        
        guard let query = field.text else {
            if completer.isSearching {
                completer.cancel()
            }
            return
        }
        
        completer.queryFragment = query
    }
    
    private func showSuggestion(_ suggestion: String) {
        suggestionLabel.text = suggestion
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print("Location")
        }
        
        guard let location = locations.first else { return }
        
        /// Returns an array of placemarks in its completion handler
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] places, _ in
            guard
                let self = self,
                let firstPlace = places?.first,
                self.nameOfPlace.text == nil
            else {
                return
            }
            
            /// Store location and update
            self.currentPlace = firstPlace
            self.nameOfPlace.text = firstPlace.name
        }
    }
    
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

// MARK: - MKLocalSearchCompleterDelegate

extension ViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard let firstResult = completer.results.first else {
            return
        }
        showSuggestion(firstResult.title)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error suggesting a location: \(error.localizedDescription)")
    }
}
