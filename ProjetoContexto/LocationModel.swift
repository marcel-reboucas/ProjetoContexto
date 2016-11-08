//
//  LocationModel.swift
//  WhatsTheWeatherIn
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/7/16.
//  Copyright © 2016 marinbenc. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationModel {

    var coordinates : CLLocationCoordinate2D
    var latitude : CLLocationDegrees
    var longitude : CLLocationDegrees
    var altitude : CLLocationDistance
    var speed : CLLocationSpeed
    
    var currentCity : String
    
    var description : String {
        get {
            return "(Latitude: \(latitude), " +
                    "Longitude: \(longitude), " +
                    "Altitude: \(altitude), " +
                    "Speed: \(speed) )"
        }
    }
    
    init(location: CLLocation, city: String = "") {
        self.coordinates = location.coordinate
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.speed = location.speed
        self.currentCity = city
    }

}
