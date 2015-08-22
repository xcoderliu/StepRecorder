//
//  HealthManager.swift
//  pedometer
//
//  Created by 刘智民 on 1/7/15.
//  Copyright (c) 2015年 刘智民. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        
        let healthKitTypesToWrite: Set = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
        ]
        
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.hihex.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if completion != nil {
                completion(success:false, error:error)
            }
            return;
        }
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil) { (success, error) -> Void in
            
            if completion != nil {
                completion(success:success,error:error)
            }
        }
    }
    
    func saveStepsSample( steps: Double, endDate: NSDate , duration :Int, completion: ( (Bool, NSError!) -> Void)!) {
        let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let stepsQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: steps)
        let startDate = endDate.dateByAddingTimeInterval(0 - 60 * Double(duration))
        let stepsSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount), quantity: stepsQuantity, startDate: startDate, endDate: endDate)
        
        self.healthKitStore.saveObject(stepsSample, withCompletion: { (success, error) -> Void in
            completion(success,error)
        })
    }
    
    func readStepsWorksout(limit :Int,completion: (([AnyObject]!, NSError!) -> Void)!) {
        let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForObjectsFromSource(HKSource.defaultSource())
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                if let queryError = error {
                    println( "There was an error while reading the samples: \(queryError.localizedDescription)")
                }
                completion(results,error)
        }
        healthKitStore.executeQuery(sampleQuery)
    }
    
    func removeSample (sample :HKQuantitySample, completion: ( (Bool, NSError!) -> Void)!) {
        self.healthKitStore.deleteObject(sample, withCompletion: { (results, error) -> Void in
            completion(results,error)
        })
    }
}










