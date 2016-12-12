//
//  PreferredLocation.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/14/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import CoreLocation

public class PreferredLocation : NSObject {
    
    var name: String
    var location : CLLocation
    var rangeInMeters : Double
    
    init(name: String, location : CLLocation, rangeInMeters : Double) {
        self.name = name
        self.location = location
        self.rangeInMeters = rangeInMeters
    }
}

extension PreferredLocation : Comparable {}

public func ==(location1: PreferredLocation, location2: PreferredLocation) -> Bool {
    return location1.name == location2.name
}

public func <(location1: PreferredLocation, location2: PreferredLocation) -> Bool {
    return false
}

public func >(location1: PreferredLocation, location2: PreferredLocation) -> Bool {
    return false
}

