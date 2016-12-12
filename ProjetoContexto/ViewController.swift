//
//  ViewController.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/7/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = LocationHandler.sharedInstance
    let weatherManager = WeatherHandler.sharedInstance
    let healthManager = HealthHandler.sharedInstance
    let deviceManager = DeviceHandler.sharedInstance
    let ruleManager = RuleHandler.sharedInstance

    // Maps a key to a value
    typealias DataValue = (name: String, value: String)
    var dataHeaders = [String]()
    var dataValues = [String : [DataValue]]()
    
    //MARK: View life-cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
       
        locationManager.delegates.append(self)
        weatherManager.delegates.append(self)
        healthManager.delegates.append(self)
        deviceManager.delegates.append(self)
        ruleManager.delegates.append(self)

        //Preferences
        let home = PreferredLocation(name: "Home", location: CLLocation(latitude: -8.051622, longitude: -34.905936), rangeInMeters: 30.0)
        locationManager.registerLocation(home)
        
        let cin = PreferredLocation(name: "CIn", location: CLLocation(latitude: -8.055393, longitude: -34.951784), rangeInMeters: 100.0)
        locationManager.registerLocation(cin)
    
    
        let contextClassBeacon = BeaconInfo(name: "Context Class", uuid: NSUUID(UUIDString: "B0702880-A295-A8AB-F734-031A98A512DE")! , majorValue: 5, minorValue: 1000)
        locationManager.registerBeacon(contextClassBeacon)

        
        //Rules
  
        let date = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let startHour = cal.dateBySettingHour(13, minute: 0, second: 0, ofDate: date, options: [])!
        let endHour = cal.dateBySettingHour(15, minute: 0, second: 0, ofDate: date, options: [])!
        
        let contextClassBeginTimeRule = ContextRule<NSDate>(attribute: .DeviceTime, operation: .IsGreaterThan, value: startHour)
        
        let contextClassEndTimeRule = ContextRule<NSDate>(attribute: .DeviceTime, operation: .IsLesserThan, value: endHour)
        
        let contextClassRoomRule = ContextRule<BeaconInfo>(attribute: .BeaconsInRange, operation: .Contains, value: contextClassBeacon)

        let contextClassRule = ContextRuleSet(rules: [contextClassBeginTimeRule, contextClassEndTimeRule, contextClassRoomRule], rulesAreTrueCallback: {
            
            let key = "Context Class Rule"
            var ruleData = [DataValue]()
            ruleData.append(DataValue("Rule is true", "Context Class!"))
            
            if !self.dataHeaders.contains(key) {
                self.dataHeaders.append(key)
            }
            
            self.dataValues[key] = ruleData
            self.tableView.reloadData()
            

        }) {
            let key = "Context Class Rule"
            self.dataHeaders.removeObject(key)
            self.dataValues.removeValueForKey(key)
            self.tableView.reloadData()
        }
        
        ruleManager.addRuleSet(contextClassRule)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: TableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataHeaders.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return dataValues[dataHeaders[section]]!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataHeaders[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        let dataValue = dataValues[dataHeaders[indexPath.section]]![indexPath.row]
        
        cell.textLabel?.text = dataValue.name
        cell.detailTextLabel?.text = dataValue.value
        
        return cell
    }
}

extension ViewController : LocationHandlerDelegate {
    
    func locationWasUpdated(location: LocationModel) {
        
        let key = "Location"
        var locationData = [DataValue]()
        
        locationData.append(DataValue("Latitude", location.latitude.description))
        locationData.append(DataValue("Longitude", location.longitude.description))
        locationData.append(DataValue("Altitude", location.altitude.description))
        locationData.append(DataValue("Speed", location.speed.description))
        
        if let preferredLocation = location.preferredLocation {
            locationData.append(DataValue("Current Location", preferredLocation.name))
        }
        
        print(location.beaconsInRange)
        if let beaconsInRange = location.beaconsInRange {
            
            
            for (index, beacon) in beaconsInRange.enumerate() {
                locationData.append(DataValue("Beacon \(index) Name:", beacon.name))
               
                if let beaconData = beacon.lastSeenBeacon {
                    locationData.append(DataValue("Beacon \(index) Proximity:", "\(beaconData.proximity.description)"))
                }
            }
            
        }
        
        if !dataHeaders.contains(key) {
            dataHeaders.append(key)
        }
        
        dataValues[key] = locationData
        tableView.reloadData()
    }
}

extension ViewController : WeatherHandlerDelegate {
    
    func weatherWasUpdated(weather: WeatherInfo) {
        
        let key = "Weather"
        var weatherData = [DataValue]()
        
        weatherData.append(DataValue("Region", weather.cityName))
        weatherData.append(DataValue("Country", weather.country))
        weatherData.append(DataValue("Weather", weather.weather))
        weatherData.append(DataValue("Temperature", weather.temperatureCurrent.description))
        weatherData.append(DataValue("Humidity", weather.humidity.description))
        
        if let sunrise = weather.sunrise {
            weatherData.append(DataValue("Sunrise", weatherManager.dateFormatter.stringFromDate(sunrise)))
        }
        
        if let sunset = weather.sunset {
            weatherData.append(DataValue("Sunset", weatherManager.dateFormatter.stringFromDate(sunset)))
        }
        
        if let dayTime = weather.dayTime {
            weatherData.append(DataValue("DayTime", dayTime.rawValue))
        }
        
        if !dataHeaders.contains(key) {
            dataHeaders.append(key)
        }
        
        dataValues[key] = weatherData
        tableView.reloadData()
    }
}

extension ViewController : HealthHandlerDelegate {
    
    // TODO: NOT OPTIMAL - IS BEING CALLED 4 TIMES AT EACH UPDATE.
    func healthWasUpdated(healthModel: HealthModel) {
        
        let key = "Health"
        var healthData = [DataValue]()
        
        if let steps = healthModel.steps {
            healthData.append(DataValue("Steps", steps.description))
        }
        
        if let stairFlights = healthModel.stairFlights {
            healthData.append(DataValue("Stair Flights", stairFlights.description))
        }
        
        if let walkingDistance = healthModel.walkingRunningDistance {
            healthData.append(DataValue("Walking Distance", walkingDistance.description))
        }
        
        if let cyclingDistance = healthModel.cyclingDistance {
            healthData.append(DataValue("Cycling Distance", cyclingDistance.description))
        }
        
        if !dataHeaders.contains(key) {
            dataHeaders.append(key)
        }
        
        dataValues[key] = healthData
        tableView.reloadData()
    }
}

extension ViewController : DeviceHandlerDelegate {
    
    func deviceWasUpdated(deviceInfo: DeviceInfo) {
        
        let key = "Device"
        var deviceData = [DataValue]()
        
        if let batteryLevel = deviceInfo.batteryLevel {
            deviceData.append(DataValue("Battery Level", batteryLevel.description))
        }
        
        if let batteryState = deviceInfo.batteryState {
            deviceData.append(DataValue("Battery State", "\(batteryState.description)"))
        }
        
        if let orientation = deviceInfo.orientation {
            deviceData.append(DataValue("Orientation", "\(orientation.description)"))
        }
        
        if let time = deviceInfo.time {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            deviceData.append(DataValue("Time", formatter.stringFromDate(time)))
        }
        
        if !dataHeaders.contains(key) {
            dataHeaders.append(key)
        }
        
        dataValues[key] = deviceData
        tableView.reloadData()
    
    }
}

extension ViewController : RuleHandlerDelegate {

    func rulesChangedToTrue(rules : [ContextRuleSet]) {
        print("rulesChangedToTrue")
        for rule in rules { rule.rulesAreTrueCallback?() }
    }

    func rulesChangedToFalse(rules : [ContextRuleSet]) {
        for rule in rules { rule.rulesAreFalseCallback?() }
    }

}
