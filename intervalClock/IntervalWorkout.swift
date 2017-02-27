//
//  IntervalWorkout.swift
//  intervalClock
//
//  Created by David Milliner on 2/23/17.
//  Copyright © 2017 David Milliner. All rights reserved.
//

import Foundation

class IntervalWorkout: NSObject, NSCoding{
    
    private var valueActive: Double!
    private var valueRest: Double!
    private var valueRounds: Int!
    private var valueTitle: String!
    
    
    var activeValue: Double {
        get {
            return valueActive
        }
        set {
            valueActive = newValue
        }
    }
    
    var restValue: Double {
        get {
            return valueRest
        }
        set {
            valueRest = newValue
        }
    }
    
    var roundsValue: Int {
        get {
            return valueRounds
        }
        set {
            valueRounds = newValue
        }
    }
    
    var titleValue: String {
        get {
            return valueTitle
        }
        set {
            valueTitle = newValue
        }
    }
    
    init(activeValue: Double, restValue: Double, roundsValue: Int, titleValue: String) {
        valueActive = activeValue
        valueRest = restValue
        valueRounds = roundsValue
        valueTitle = titleValue
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let valueActive = aDecoder.decodeObject(forKey: "valueActive")
        let valueRest = aDecoder.decodeObject(forKey: "valueRest")
        let valueRounds = aDecoder.decodeObject(forKey: "valueRounds")
        let valueTitle = aDecoder.decodeObject(forKey: "valueTitle")
        self.init(activeValue: valueActive as! Double, restValue: valueRest as! Double, roundsValue: valueRounds as! Int, titleValue: valueTitle as! String)
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(valueActive, forKey: "valueActive")
        aCoder.encode(valueRest, forKey: "valueRest")
        aCoder.encode(valueRounds, forKey: "valueRounds")
        aCoder.encode(valueTitle, forKey: "valueTitle")
    }
}
