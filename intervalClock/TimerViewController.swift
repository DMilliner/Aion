//
//  TimerViewController.swift
//  IntervalClock
//
//  Created by David Milliner on 2/22/17.
//  Copyright © 2017 David Milliner. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

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
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.orange

        navigationItem.title = valueTitle
        
        activeCounter = valueActive
        restCounter = valueRest
        roundsMax = valueRounds
        
        workoutProgress.progress = 0
        workoutProgress.transform = workoutProgress.transform.scaledBy(x: 1, y: 16)
        timeValueLabel.text = valueActive.description
        
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.green.cgColor
        resetButton.layer.borderWidth = 2
        resetButton.layer.borderColor = UIColor.white.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

    }
    
    func appMovedToBackground() {
        print("App moved to background!")
    }
    
    func updateActiveCounter() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ActiveBackground")!)

        if activeCounter >= 0.10 {
            let timeString = String(format: "%.2f", activeCounter)
            timeValueLabel.text = timeString
            activeCounter -= 0.05
        } else {
            roundsMax -= 1
            if roundsMax > 0{
                restCounter = valueRest
                activeTimer?.invalidate()
                
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                AudioServicesPlaySystemSound (1257)
                
                restTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateRestCounter), userInfo: nil, repeats: true)
                restTimer?.fire()
            } else {
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "DoneBackground")!)
                restTimer?.invalidate()
                activeTimer?.invalidate()
                timeValueLabel.text = "Done"
                workoutProgress.progress = 100
            }
        }
    }
    
    func updateRestCounter() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "RestBackground")!)

        if restCounter >= 0.10 {
            let timeString = String(format: "%.2f", restCounter)
            timeValueLabel.text = timeString
            restCounter -= 0.05

        } else {
            activeCounter = valueActive
            currentRoundsValue += 1
            print("Rounds \(currentRoundsValue)")

            workoutProgress.progress = Float(Double(currentRoundsValue)/Double(valueRounds))
            restTimer?.invalidate()
            
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound (1258)

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
        currentRoundsValue = 0
        workoutProgress.progress = 0
        timeValueLabel.text = valueActive.description
        
        self.view.backgroundColor = UIColor.black
        
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.green, for: .normal)
        startButton.backgroundColor = UIColor.init(red: 0, green: 144/255, blue: 0, alpha: 0.42)
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.green.cgColor
        pausedDuringRestTime = false
        running = false
        
        activeTimer?.invalidate()
        restTimer?.invalidate()

    }
    
    @IBAction func pressedStart(_ sender: UIButton){
        print("Start or Pause")

        if running == false {
            startButton.setTitle("Pause", for: .normal)
            startButton.setTitleColor(UIColor.green, for: .normal)
            startButton.backgroundColor = UIColor.init(red: 0, green: 144/255, blue: 0, alpha: 0.42)
            startButton.layer.borderWidth = 2
            startButton.layer.borderColor = UIColor.green.cgColor
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
            startButton.setTitle("Resume", for: .normal)
            startButton.setTitleColor(UIColor.orange, for: .normal)
            startButton.backgroundColor = UIColor.init(red: 144/255, green: 72/255, blue: 0, alpha: 0.42)
            startButton.layer.borderWidth = 2
            startButton.layer.borderColor = UIColor.orange.cgColor
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
