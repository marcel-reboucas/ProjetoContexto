//
//  ContextRule.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 12/12/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import Foundation

enum ContextAttribute {
    
    case DeviceTime
    case DeviceBatteryLevel
    case DeviceBatteryState
    case DeviceOrientation
    case CurrentCity
    case BeaconsInRange
    
    var model: NSObject? {
        switch self {
        case DeviceTime,
             DeviceBatteryLevel,
             DeviceBatteryState,
             DeviceOrientation:
            return DeviceHandler.sharedInstance.deviceInfo
        case .CurrentCity,
             .BeaconsInRange:
            return LocationHandler.sharedInstance.location
        }
    }
    
    var propertyName: String {
        switch self {
        case DeviceTime:
            return "time"
        case DeviceBatteryLevel:
            return "batteryLevel"
        case DeviceBatteryState:
            return "batteryState"
        case DeviceOrientation:
            return "orientation"
        case .CurrentCity:
            return "currentCity"
        case .BeaconsInRange:
            return "beaconsInRange"
        }
    }
    
}

enum ContextOperation {
    case Equal
    case NotEqual
    case IsLesserThan
    case IsGreaterThan
    case Contains
    
    func applies<T: Comparable>(contextValue: T, ruleValue: T) -> Bool {
        switch self {
        case Equal:
            return contextValue == ruleValue
        case NotEqual:
            return contextValue != ruleValue
        case IsLesserThan:
            return contextValue < ruleValue
        case IsGreaterThan:
            return contextValue > ruleValue
        default:
            return false
        }
    }
    
    func applies<T: Comparable>(contextValues: [T], ruleValue: T) -> Bool {
        switch self {
        case .Contains:
            return contextValues.contains(ruleValue)
        default:
            return false
        }
    }
    
}

protocol ContextRuleProtocol {
    func applies() -> Bool
}

struct ContextRule<T: Comparable> : ContextRuleProtocol {
    
    var attribute : ContextAttribute
    var operation : ContextOperation
    var value : T
    
    func applies() -> Bool {
        
        let contextValue = attribute.model?.valueForKey(attribute.propertyName)
        
        switch operation {
        case .Contains:
            if let contextValues = contextValue as? [T] {
                return operation.applies(contextValues, ruleValue: value)
            }
        default:
            if let contextValue = contextValue as? T {
                return operation.applies(contextValue, ruleValue: value)
            }
        }
        
        return false
    }
}