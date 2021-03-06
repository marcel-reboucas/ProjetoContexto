//
//  Extensions.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/7/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[startIndex.advancedBy(i)]
        }
    }
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

extension CLProximity {
    var description : String {
        switch self {
        case .Unknown:    return "Unknown";
        case .Far:        return "Far";
        case .Near:       return "Near";
        case .Immediate:  return "Immediate";
        }
    }
}


extension UIDeviceOrientation : CustomStringConvertible {

    public var description : String {
        get {
            switch self {
            case .FaceDown:
                return "FaceDown"
            case .FaceUp:
                return "FaceUp"
            case .LandscapeLeft:
                return "LandscapeLeft"
            case .LandscapeRight:
                return "LandscapeRight"
            case .Portrait:
                return "Portrait"
            case .PortraitUpsideDown:
                return "PortraitUpsideDown"
            default:
                return "Unknown"
            }
        }
    }
}

extension UIDeviceBatteryState : CustomStringConvertible {
    
    public var description : String {
        get {
            switch self {
            case .Charging:
                return "Charging"
            case .Full:
                return "Full"
            case .Unplugged:
                return "Unplugged"
            default:
                return "Unknown"
            }
        }
    }
}