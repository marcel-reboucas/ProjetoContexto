//
//  WeatherInfo.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/7/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import SwiftyJSON

public class WeatherInfo {
    
    var cityName : String
    var country : String
    var weather : String
    var temperatureCurrent : Double
    var temperatureMin : Double
    var temperatureMax : Double
    var pressure : Double
    var seaLevel : Double
    var humidity : Double
    var windSpeed : Double
    var windDegree : Double
    
    var description : String {
        get {
            return "(cityName: \(cityName), " +
                "country: \(country), " +
                "weather: \(weather), " +
                "temperatureCurrent: \(temperatureCurrent), " +
                "pressure: \(pressure), " +
                "seaLevel: \(seaLevel), " +
                "humidity: \(humidity), " +
                "windSpeed: \(windSpeed), " +
                "windDegree: \(windDegree) )"
        }
    }
    
    init (data : JSON) {
        
        // Location
        self.cityName = data["name"].stringValue
        self.country = data["sys"]["country"].stringValue
        
        // Weather
        self.weather = data["weather"][0]["main"].stringValue
        
        //Temperature
        self.temperatureCurrent = data["main"]["temp"].doubleValue
        self.temperatureMin = data["main"]["temp_min"].doubleValue
        self.temperatureMax = data["main"]["temp_max"].doubleValue
    
        // Wind
        self.windSpeed = data["wind"]["speed"].doubleValue
        self.windDegree = data["wind"]["deg"].doubleValue
        
        // Others
        self.pressure = data["main"]["pressure"].doubleValue
        self.seaLevel = data["main"]["sea_level"].doubleValue
        self.humidity = data["main"]["humidity"].doubleValue
    }
}
