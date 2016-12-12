//
//  BeaconInfo.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/23/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import Foundation
import CoreLocation

struct BeaconConstant {
    static let nameKey = "name"
    static let uuidKey = "uuid"
    static let majorKey = "major"
    static let minorKey = "minor"
}

class BeaconInfo: NSObject {
    let name: String
    let uuid: NSUUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    var lastSeenBeacon: CLBeacon?
    
    init(name: String, uuid: NSUUID, majorValue: CLBeaconMajorValue, minorValue: CLBeaconMinorValue) {
        self.name = name
        self.uuid = uuid
        self.majorValue = majorValue
        self.minorValue = minorValue
    }
    
}

extension BeaconInfo : Comparable {}

func ==(rhs: BeaconInfo, lsh: BeaconInfo) -> Bool {
    return rhs.name == lsh.name
}

func <(rhs: BeaconInfo, lsh: BeaconInfo) -> Bool {
    return false
}

func >(rhs: BeaconInfo, lsh: BeaconInfo) -> Bool {
    return false
}

func ==(beacon: CLBeacon, beaconInfo: BeaconInfo) -> Bool {
    return ((beacon.proximityUUID.UUIDString == beaconInfo.uuid.UUIDString)
        && (Int(beacon.major) == Int(beaconInfo.majorValue))
        && (Int(beacon.minor) == Int(beaconInfo.minorValue)))
}

func ==(beaconInfo: BeaconInfo, beacon: CLBeacon) -> Bool {
    return beacon == beaconInfo
}

