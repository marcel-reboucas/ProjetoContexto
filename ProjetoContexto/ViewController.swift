//
//  ViewController.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/7/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LocationHandlerDelegate, WeatherHandlerDelegate {

    let locationManager = LocationHandler.sharedInstance
    let weatherManager = WeatherHandler.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegates.append(self)
        weatherManager.delegates.append(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationWasUpdated(location: LocationModel) {
        print(location.description)
    }
    
    func weatherWasUpdated(weather: WeatherInfo) {
        print(weather.description)
    }

}

