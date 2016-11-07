//
//  WeatherHandler.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/7/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import OpenWeatherMapAPI

protocol WeatherHandlerDelegate {
    func weatherWasUpdated(weather : WeatherInfo)
}

class WeatherHandler : NSObject {
    
    // Singleton
    static let sharedInstance = WeatherHandler()
    
    typealias WeatherResultBlock = (result: Result<WeatherInfo, Error>) -> ()
    
    private let API_KEY = "6a700a1e919dc96b0a98901c9f4bec47"
    private let weatherApi : OWMWeatherAPI
    
    var delegates = [WeatherHandlerDelegate]()
    var weatherInfo : WeatherInfo? {
        didSet {
            if let weatherInfo = self.weatherInfo {
                for delegate in delegates { delegate.weatherWasUpdated(weatherInfo)}
            }
        }
    }
    private var timedFunction : NSTimer?
    var timeBetweenUpdates : NSTimeInterval = 10.0
    
    private override init() {
        
        weatherApi = OWMWeatherAPI(APIKey: API_KEY)
        weatherApi.setTemperatureFormat(kOWMTempCelcius)
        
        super.init()
        
        timedFunction = NSTimer.scheduledTimerWithTimeInterval(timeBetweenUpdates, target: self, selector:  #selector(WeatherHandler.updateCurrentWeatherInfo), userInfo: nil, repeats: true)
    }
    
    deinit {
        timedFunction?.invalidate()
    }

    func getWeatherInfoWithCoordinates(coordinates : CLLocationCoordinate2D, callbackBlock: WeatherResultBlock?) {
    
        weatherApi.currentWeatherByCoordinate(coordinates, withCallback: {
            (error, result) -> Void in
            
            if let result = result {
                let weather : WeatherInfo = WeatherInfo(data: JSON(result))
                self.weatherInfo = weather
                print(weather.description)
                callbackBlock?(result: Result.Success(weather))
                
            } else {
                let error = Error(code: error.code, message: error.localizedDescription)
                print(error)
                callbackBlock?(result: Result.Failure(error))
            }
        })
    }
    
    func getWeatherInfoWithCity(cityName : String, callbackBlock: WeatherResultBlock?) {
        
        weatherApi.currentWeatherByCityName(cityName, withCallback: {
            (error, result) -> Void in
            
            if let result = result {
                let weather : WeatherInfo = WeatherInfo(data: JSON(result))
                self.weatherInfo = weather
                print(weather.description)
                callbackBlock?(result: Result.Success(weather))
                
            } else {
                let error = Error(code: error.code, message: error.localizedDescription)
                print(error)
                callbackBlock?(result: Result.Failure(error))
            }
        })
    }
    
    func updateCurrentWeatherInfo() {
        
        let locationManager = LocationHandler.sharedInstance
        
        if let coordinates = locationManager.location?.coordinates {
            //Updates the weatherInfo object.
            getWeatherInfoWithCoordinates(coordinates, callbackBlock: nil)
        }
    }
}
