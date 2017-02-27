//
//  TimerViewController.swift
//  IntervalClock
//
//  Created by David Milliner on 2/22/17.
//  Copyright © 2017 David Milliner. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var workoutProgress: UIProgressView!

    var activeCounter: Double = 0.0
    var restCounter: Double = 0.0
    var roundsMax: Int = 0
    
    var valueActive: Double = 0.0
    var valueRest: Double = 0.0
    var valueRounds: Int = 0
    
    var valueTitle: String = ""
    var running:Bool = false
    var pausedDuringRestTime:Bool = false
    var currentRoundsValue: Int = 0

    weak var activeTimer: Timer?
    weak var restTimer: Timer?

    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = valueTitle
        
        activeCounter = valueActive
        restCounter = valueRest
        roundsMax = valueRounds
        
        workoutProgress.progress = 0
        workoutProgress.transform = workoutProgress.transform.scaledBy(x: 1, y: 16)
        timeValueLabel.text = valueActive.description

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        


    }
    
    func updateActiveCounter() {

//        self.view.applyGradient(colours: [UIColor.yellow, UIColor.blue, UIColor.red], locations: [0.0, 0.5, 1.0])
//        self.view.applyGradient(colours: [UIColor.yellow, UIColor.blue])
        self.view.backgroundColor = UIColor.red

        if activeCounter >= 0.10 {
            let timeString = String(format: "%.2f", activeCounter)
            timeValueLabel.text = timeString
            activeCounter -= 0.05
        } else {
            roundsMax -= 1
            if roundsMax > 0{
                restCounter = valueRest
                
                activeTimer?.invalidate()
                
                restTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateRestCounter), userInfo: nil, repeats: true)
                restTimer?.fire()
            } else {
                self.view.backgroundColor = UIColor.purple
                restTimer?.invalidate()
                activeTimer?.invalidate()
                timeValueLabel.text = "Done"
                workoutProgress.progress = 100
            }
        }
    }
    
    func updateRestCounter() {
        self.view.backgroundColor = UIColor.green
        if restCounter >= 0.10 {
            let timeString = String(format: "%.2f", restCounter)
            timeValueLabel.text = timeString
            restCounter -= 0.05
        } else {
            activeCounter = valueActive
            currentRoundsValue += 1

            workoutProgress.progress = Float(Double(currentRoundsValue)/Double(valueRounds))
            restTimer?.invalidate()
            
            activeTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateActiveCounter), userInfo: nil, repeats: true)
            activeTimer?.fire()
        }
    }
    
    @IBAction func backToTableView(_ sender: UIButton){
        print("Cancel")
        restTimer?.invalidate()
        activeTimer?.invalidate()
    }
    
    @IBAction func pressedReset(_ sender: UIButton){
        print("Reset")
        activeCounter = valueActive
        restCounter = valueRest
        roundsMax = valueRounds
        
        workoutProgress.progress = 0
        timeValueLabel.text = valueActive.description
        self.view.backgroundColor = UIColor.white
        
        startButton.setTitle("Start", for: .normal)
        pausedDuringRestTime = false
        running = false
        
        activeTimer?.invalidate()
        restTimer?.invalidate()

    }
    
    @IBAction func pressedStart(_ sender: UIButton){
        print("Start or Pause")

        if running == false {
            startButton.setTitle("Pause", for: .normal)
            running = true

            if pausedDuringRestTime {
                restTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateRestCounter), userInfo: nil, repeats: true)
                restTimer?.fire()
                pausedDuringRestTime = false
            } else {
                activeTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateActiveCounter), userInfo: nil, repeats: true)
                activeTimer?.fire()
            }

        } else {
            startButton.setTitle("Start", for: .normal)
            running = false

            if activeTimer != nil && restTimer == nil {
                activeTimer?.invalidate()
            } else if activeTimer == nil && restTimer != nil{
                restTimer?.invalidate()
                pausedDuringRestTime = true
            }
        }
    }
}

//extension UIView {
//    func applyGradient(colours: [UIColor]) -> Void {
//        self.applyGradient(colours: colours, locations: nil)
//    }
//    
//    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = self.bounds
//        gradient.colors = colours.map { $0.cgColor }
//        gradient.locations = locations
//        self.layer.insertSublayer(gradient, at: 0)
//    }
//}
