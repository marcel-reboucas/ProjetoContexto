//
//  HealthHandler.swift
//  ProjetoContexto
//
//  Created by Marcel de Siqueira Campos Rebouças on 11/16/16.
//  Copyright © 2016 mscr. All rights reserved.
//

import HealthKit

protocol HealthHandlerDelegate {
    func healthWasUpdated(healthModel : HealthModel)
}

enum DistanceType {
    case WalkingRunning
    case Cycling
}

class HealthHandler: NSObject  {
    
    // Singleton
    static let sharedInstance = HealthHandler()
    
    var delegates = [HealthHandlerDelegate]()
    var healthModel : HealthModel? {
        didSet {
            if let healthModel = self.healthModel {
                for delegate in delegates { delegate.healthWasUpdated(healthModel)}
            }
        }
    }
    
    let healthStore: HKHealthStore?
    
    override init() {
        
        healthStore = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
        
        super.init()
        
        if let healthStore = healthStore {
            
            // We cannot access the user's HealthKit data without specific permission.
            // Seek authorization in HealthKitManager.swift.
            authorizeHealthKit (healthStore) { (authorized,  error) -> Void in
                if authorized {
                    print("Authorized")
                    self.updateInformation()
                } else {
                    if error != nil { print(error) }
                    print("Permission denied.")
                }
            }
        }
        
        print("Starting HealthHandler")
    }
    
    func updateInformation() {
        
        let now = NSDate()
        let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(now)
        
        self.getStepsInformation(startOfToday, toDate: now)
        self.getDistanceInformation(.WalkingRunning,fromDate: startOfToday, toDate: now)
        self.getDistanceInformation(.Cycling,fromDate: startOfToday, toDate: now)
        self.getFlightsClimbedInformation(startOfToday, toDate: now)

    }
    
    private func authorizeHealthKit(healthKitStore: HKHealthStore, completion: ((success: Bool, error: NSError!) -> Void)!) {
        
        // State the health data type(s) we want to read from HealthKit.
        var healthDataToRead : Set<HKObjectType> = Set()
        healthDataToRead.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
        healthDataToRead.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!)
        healthDataToRead.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!)
        healthDataToRead.insert(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!)
        
        // State the health data type(s) we want to write from HealthKit.
        let healthDataToWrite : Set<HKSampleType> = Set()
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        // Request authorization to read and/or write the specific data.
        healthKitStore.requestAuthorizationToShareTypes(healthDataToWrite, readTypes: healthDataToRead) { (success, error) -> Void in
            if( completion != nil ) {
                completion(success:success, error:error)
            }
        }
    }
    
    private func getData(sampleType: HKSampleType, fromDate: NSDate, toDate: NSDate, completion: (([HKSample]?, NSError!) -> Void)!) {
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(fromDate, endDate: toDate, options: .None)
        
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        let stepQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit , sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error ) -> Void in
            
            if let queryError = error {
                completion(nil, queryError)
                return
            }
            
            if completion != nil {
                completion(results, nil)
            }
        }
        
        // Time to execute the query.
        self.healthStore?.executeQuery(stepQuery)
    }
    
    func getFlightsClimbedInformation(fromDate: NSDate, toDate: NSDate) {
        
        // Create the HKSample for stairs.
        let stepSample = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
        
        // Call HealthKitManager's getSample() method to get the user's stairs info.
        self.getData(stepSample!, fromDate: fromDate, toDate: toDate, completion: { (flightsClimbed, error) -> Void in
            
            var totalFlightsClimbed = 0.0
            if  let flightsClimbed = flightsClimbed as? [HKQuantitySample] {
                for flights in flightsClimbed {
                    totalFlightsClimbed = totalFlightsClimbed + flights.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
            }
            print("Flights today: \(totalFlightsClimbed)")
        })
    }
    
    
    func getStepsInformation(fromDate: NSDate, toDate: NSDate) {
        
        // Create the HKSample for step.
        let stepSample = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Call HealthKitManager's getSample() method to get the user's step info.
        self.getData(stepSample!, fromDate: fromDate, toDate: toDate, completion: { (userSteps, error) -> Void in
            
            var totalSteps = 0.0
            if  let steps = userSteps as? [HKQuantitySample] {
                for step in steps {
                    totalSteps = totalSteps + step.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
            }
            print("Steps today: \(totalSteps)")
        })
    }
    
    func getDistanceInformation(type: DistanceType, fromDate: NSDate, toDate: NSDate) {
        
        // Create the HKSample for distance.
        var distanceSample : HKSampleType
        
        switch type {
        case .Cycling:
            distanceSample = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)!
        case .WalkingRunning:
             distanceSample = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
        }
        
        // Call HealthKitManager's getSample() method to get the user's distance info.
        self.getData(distanceSample, fromDate: fromDate, toDate: toDate, completion: { (distances, error) -> Void in
            
            var totalDistance = 0.0
            if  let distances = distances as? [HKQuantitySample] {
                for distance in distances {
                    totalDistance = totalDistance + distance.quantity.doubleValueForUnit(HKUnit.meterUnit())
                }
            }
            print("Distance today: \(totalDistance) meters.")
        })
    }
    
   
}
