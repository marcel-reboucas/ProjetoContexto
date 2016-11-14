//
//  PreferredLocation.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/14/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import CoreLocation

struct PreferredLocation {
    
    var name: String
    var location : CLLocation
    var rangeInMeters : Double
    
    init(name: String, location : CLLocation, rangeInMeters : Double) {
        self.name = name
        self.location = location
        self.rangeInMeters = rangeInMeters
    }
}
