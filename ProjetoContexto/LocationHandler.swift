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
    
    private var registeredBeacons = [BeaconInfo]()
    
    let timeBetweenLocationUpdates = 10.0
    var locationTimeCounter = 10.0
    
    let timeBetweenBeaconUpdates = 10.0
    var beaconTimeCounter = 10.0
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        print("Starting LocationHandler")
    }
    
    deinit {
        self.locationManager.delegate = nil
        self.locationManager.stopUpdatingLocation()
        
        for beacon in registeredBeacons {
            stopMonitoringBeacon(beacon)
        }
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
        
        if locationTimeCounter < timeBetweenLocationUpdates {
            locationTimeCounter = locationTimeCounter + 1.0
            return
        }
        
        locationTimeCounter = 0.0
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
            
            if let error = error {
                print("Error:  \(error.localizedDescription)")
                self.location = LocationModel(location: newLocation)
            } else {
                
                let placemark = placemarks!.last! as CLPlacemark
                
                if let city = placemark.locality {
                    
                    var locationModel = LocationModel(location: newLocation, city: city)
                    locationModel.preferredLocation = self.getClosestPreferredLocation(locationModel)
                    locationModel.beaconsInRange = self.location?.beaconsInRange
                    
                    self.location = locationModel
                }
            }
        })
    }
    
    func registerLocation(location: PreferredLocation) {
        userPreferredLocations.append(location)
    }
    
    func removeLocation(location: PreferredLocation) {
        userPreferredLocations.removeObject(location)
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
    
    //MARK: Beacon
    
    func registerBeacon(beacon: BeaconInfo) {
        if !registeredBeacons.contains(beacon) {
            print("Registered beacon: \(beacon.name)")
            registeredBeacons.append(beacon)
            startMonitoringBeacon(beacon)
        }
    }
    
    func removeBeacon(beacon: BeaconInfo) {
        if registeredBeacons.contains(beacon) {
            registeredBeacons.removeObject(beacon)
            stopMonitoringBeacon(beacon)
        }
    }
    
    private func beaconRegionWithBeacon(beacon: BeaconInfo) -> CLBeaconRegion {
        let beaconRegion = CLBeaconRegion(proximityUUID: beacon.uuid, major: beacon.majorValue, minor: beacon.minorValue, identifier: beacon.name)
        return beaconRegion
    }
    
    private func startMonitoringBeacon(beacon: BeaconInfo) {
        let beaconRegion = beaconRegionWithBeacon(beacon)
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    private func stopMonitoringBeacon(beacon: BeaconInfo) {
        let beaconRegion = beaconRegionWithBeacon(beacon)
        locationManager.stopMonitoringForRegion(beaconRegion)
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Failed monitoring region: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed: \(error.description)")
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        if beaconTimeCounter < timeBetweenBeaconUpdates {
            beaconTimeCounter = beaconTimeCounter + 1.0
            return
        }
        
        beaconTimeCounter = 0.0
        
        var beaconsInRange = [BeaconInfo]()
        
        for beacon in beacons {
            for registeredBeacon in registeredBeacons {
                if beacon == registeredBeacon {
                    registeredBeacon.lastSeenBeacon = beacon
                    beaconsInRange.append(registeredBeacon)
                    print("Found beacon! \(registeredBeacon.name)")
                }
            }
        }
        
        self.location?.beaconsInRange = beaconsInRange
    }
}
