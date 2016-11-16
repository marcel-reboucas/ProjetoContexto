//
//  LocationHanderModel.swift
//  WhatsTheWeatherIn
//
//  Created by Marcel de Siqueira Campos Rebouças on 10/13/16.
//  Copyright © 2016 marinbenc. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationHandlerDelegate {
    func locationWasUpdated(location : LocationModel)
}

class LocationHandler: NSObject, CLLocationManagerDelegate  {
    
    // Singleton
    static let sharedInstance = LocationHandler()
    
    var delegates = [LocationHandlerDelegate]()
    var location : LocationModel? {
        didSet {
            if let location = self.location {
                for delegate in delegates { delegate.locationWasUpdated(location)}
            }
        }
    }
    var locationManager: CLLocationManager = CLLocationManager()
    var minimumDistanceBetweenUpdates = 10.0 {
        didSet{
            self.locationManager.distanceFilter = minimumDistanceBetweenUpdates
        }
    }
    
    private var userPreferredLocations = [PreferredLocation]() {
        didSet {
            // keeps the array sorted by range
            userPreferredLocations.sortInPlace { (lhs: PreferredLocation, rhs: PreferredLocation) -> Bool in
                return lhs.rangeInMeters < rhs.rangeInMeters
            }
        }
    }
    
    let timeBetweenUpdates = 10.0
    var timeCounter = 10.0
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        print("Starting LocationHandler")
    }
    
    deinit {
        self.locationManager.delegate = nil
        self.locationManager.stopUpdatingLocation()
    }
    
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            print(".NotDetermined")
            break
            
        case .Authorized:
            print(".Authorized")
            self.locationManager.startUpdatingLocation()
            break
            
        case .Denied:
            print(".Denied")
            break
            
        default:
            print("Unhandled authorization status")
            break
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if timeCounter < timeBetweenUpdates {
            timeCounter = timeCounter + 1.0
            return
        }
        
        timeCounter = 0.0
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
            
            if let error = error {
                print("Error:  \(error.localizedDescription)")
                self.location = LocationModel(location: newLocation)
            } else {
                
                let placemark = placemarks!.last! as CLPlacemark
                
                let userInfo = [
                    "city":     placemark.locality,
                    "state":    placemark.administrativeArea,
                    "country":  placemark.country
                ]
                
                //not safe
                let city = userInfo["city"]!!
                
                var locationModel = LocationModel(location: newLocation, city: city)
                locationModel.preferredLocation = self.getClosestPreferredLocation(locationModel)
                
                self.location = locationModel
            }
        })
    }
    
    func registerLocation(location: PreferredLocation) {
        userPreferredLocations.append(location)
    }
    
    func getClosestPreferredLocation(locationModel: LocationModel) -> PreferredLocation? {
    
        let currentLocation = locationModel.location
        var closestPreferredLocation : PreferredLocation?
        
        for preferredLocation in userPreferredLocations {
            if currentLocation.distanceFromLocation(preferredLocation.location) < preferredLocation.rangeInMeters {
                closestPreferredLocation = preferredLocation
                break
            }
        }
        
        return closestPreferredLocation
    }
}
