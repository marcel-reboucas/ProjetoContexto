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

        
        registerPreferredLocations()
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
    
    //MARK: Manager Preferences
    
    func registerPreferredLocations() {
        
        let home = PreferredLocation(name: "Home", location: CLLocation(latitude: -8.051622, longitude: -34.905936), rangeInMeters: 30.0)
        locationManager.registerLocation(home)
        
        let cin = PreferredLocation(name: "CIn", location: CLLocation(latitude: -8.055393, longitude: -34.951784), rangeInMeters: 100.0)
        locationManager.registerLocation(cin)

    }

}

extension ViewController : LocationHandlerDelegate {
    
    func locationWasUpdated(location: LocationModel) {
        
        let key = "Location"
        var locationData = [DataValue]()
        
        locationData.append(DataValue("latitude", location.latitude.description))
        locationData.append(DataValue("longitude", location.longitude.description))
        locationData.append(DataValue("altitude", location.altitude.description))
        locationData.append(DataValue("speed", location.speed.description))
        
        
        if let preferredLocation = location.preferredLocation {
            locationData.append(DataValue("currentLocation", preferredLocation.name))
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
        
        weatherData.append(DataValue("region", weather.cityName))
        weatherData.append(DataValue("country", weather.country))
        weatherData.append(DataValue("weather", weather.weather))
        weatherData.append(DataValue("temperature", weather.temperatureCurrent.description))
        weatherData.append(DataValue("humidity", weather.humidity.description))
        
        if let sunrise = weather.sunrise {
            weatherData.append(DataValue("sunrise", weatherManager.dateFormatter.stringFromDate(sunrise)))
        }
        
        if let sunset = weather.sunset {
            weatherData.append(DataValue("sunset", weatherManager.dateFormatter.stringFromDate(sunset)))
        }
        
        if let dayTime = weather.dayTime {
            weatherData.append(DataValue("dayTime", dayTime.rawValue))
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
        
        print("health was updated")
        
        let key = "Health"
        var healthData = [DataValue]()
        
        if let steps = healthModel.steps {
            healthData.append(DataValue("steps", steps.description))
        }
        
        if let stairFlights = healthModel.stairFlights {
            healthData.append(DataValue("stair flights", stairFlights.description))
        }
        
        if let walkingDistance = healthModel.walkingRunningDistance {
            healthData.append(DataValue("walking distance", walkingDistance.description))
        }
        
        if let cyclingDistance = healthModel.cyclingDistance {
            healthData.append(DataValue("cycling distance", cyclingDistance.description))
        }
        
        if !dataHeaders.contains(key) {
            dataHeaders.append(key)
        }
        
        dataValues[key] = healthData
        tableView.reloadData()
    }
}
