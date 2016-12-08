//
//  BatteryHandler.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 12/8/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import Foundation
import UIKit

protocol DeviceHandlerDelegate {
    func deviceWasUpdated(deviceInfo : DeviceInfo)
}

class DeviceHandler: NSObject {
    
    // Singleton
    static let sharedInstance = DeviceHandler()
    
    let device = UIDevice.currentDevice()
    
    var delegates = [DeviceHandlerDelegate]()
    var deviceInfo : DeviceInfo? {
        didSet {
            if let deviceInfo = deviceInfo {
                for delegate in delegates { delegate.deviceWasUpdated(deviceInfo)}
            }
        }
    }
    private var timedUpdates : NSTimer?
    var timeBetweenUpdates : NSTimeInterval = 10.0
    
    private override init() {
        
        super.init()
        
        updateCurrentDeviceInfo()
        
        timedUpdates = NSTimer.scheduledTimerWithTimeInterval(timeBetweenUpdates, target: self, selector:  #selector(DeviceHandler.updateCurrentDeviceInfo), userInfo: nil, repeats: true)
        
        device.batteryMonitoringEnabled = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DeviceHandler.deviceOrientationChanged), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        print("Starting BatteryHandler")
        
    }
    
    deinit {
        timedUpdates?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func updateCurrentDeviceInfo() {
        
        var devInfo = DeviceInfo()
        
        // Battery
        
        if device.batteryMonitoringEnabled {
            devInfo.batteryLevel = device.batteryLevel
            devInfo.batteryState = device.batteryState
        }
        
        // Orientation
        devInfo.orientation = device.orientation
        
        // Time 
        devInfo.time = NSDate()
        
        self.deviceInfo = devInfo
    }
    
    func deviceOrientationChanged() {
        print("Changed Orientation")
        updateCurrentDeviceInfo()
    }
    
    func deviceProximityChanged() {
        print("Changed Proximity")
        updateCurrentDeviceInfo()
    }
}
