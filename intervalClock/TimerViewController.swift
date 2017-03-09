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

    var activeCounter: Double = 0.0
    var restCounter: Double = 0.0
    var roundsMax: Int = 0
    
    var valueActive: Double = 0.0
    var valueRest: Double = 0.0
    var valueRounds: Int = 0
    
    var valueTitle: String = ""
    var running:Bool = false
    var isDone:Bool = false
    var pausedDuringRestTime:Bool = false
    var currentRoundsValue: Int = 0

    weak var activeTimer: Timer?
    weak var restTimer: Timer?
    
    var progressIndicatorView: CircularLoaderView?
    var valWidth: Int = 0
    
    var progressTotal: Int = 0
    var progressValue: Double = 0.0
    
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.orange
                
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "ActiveBackground")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        navigationItem.title = valueTitle

        activeCounter = valueActive
        restCounter = valueRest
        roundsMax = valueRounds
        
        timeValueLabel.text = makeValueReadable(valueActive)
        timeValueLabel.adjustsFontSizeToFitWidth = true
        timeValueLabel.numberOfLines = 1
        
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.green.cgColor
        resetButton.layer.borderWidth = 2
        resetButton.layer.borderColor = UIColor.white.cgColor
        
        
        if( self.view.frame.height >  self.view.frame.width){
            valWidth = Int(CGFloat(self.view.frame.width-16))
        } else {
            valWidth = Int(CGFloat(self.view.frame.height-16))
        }
        
        progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
        self.view.addSubview(progressIndicatorView!)
        progressIndicatorView?.frame = CGRect(x: CGFloat(Int(self.view.frame.size.width / 2) - Int(valWidth / 2)), y: CGFloat(Int(self.view.frame.size.height / 2) - Int(valWidth / 2)), width: CGFloat(valWidth), height: CGFloat(valWidth))
        progressIndicatorView?.isUserInteractionEnabled = true
        progressIndicatorView?.center = self.view.center
        progressIndicatorView?.autoresizesSubviews = true

        self.view.sendSubview(toBack: progressIndicatorView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        progressTotal = (Int(valueRounds) * Int(valueActive)) + (Int(valueRounds - 1) * Int(valueRest))

    }
    
    func makeValueReadable(_ stringActiveValue: Double)->String{
        let valueInMinute = Int(stringActiveValue.truncatingRemainder(dividingBy: 3720)/60)
        let valueInMinuteString =  String(format: "%02d", valueInMinute)

        let valueInSecond = stringActiveValue.truncatingRemainder(dividingBy: 3720).truncatingRemainder(dividingBy: 60)
        let valueInSecondString =  String(format: "%02d", Int(valueInSecond))
        
        let numberOfPlaces:Double = 2.0
        let powerOfTen:Double = pow(10.0, numberOfPlaces)
        let targetedDecimalPlaces:Double = round((valueInSecond.truncatingRemainder(dividingBy: 1.0)) * powerOfTen)
        var valueInMilliSecondString = ""
        if(targetedDecimalPlaces == 100){
            valueInMilliSecondString = "00"
        } else {
            valueInMilliSecondString =  String(format: "%02d", Int(targetedDecimalPlaces))
        }

        return valueInMinuteString + ":" + valueInSecondString + "." + valueInMilliSecondString

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isIdleTimerDisabled = true
        
        //Simulator Test
//        startButton.sendActions(for: .touchUpInside)
        
//        UIApplication.shared.applicationIconBadgeNumber = 0
//        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape {
            print("UIDevice Landscape")
            if( self.view.frame.height >  self.view.frame.width){
                valWidth = Int(CGFloat(self.view.frame.width-16))
            } else {
                valWidth = Int(CGFloat(self.view.frame.height-16))
            }
            
            progressIndicatorView?.frame = CGRect(x: CGFloat(Int(self.view.frame.size.height / 2) - Int(valWidth / 2)), y: CGFloat(Int(self.view.frame.size.width / 2) - Int(valWidth / 2)), width: CGFloat(valWidth), height: CGFloat(valWidth))
            progressIndicatorView?.autoresizesSubviews = true
            
            if pausedDuringRestTime {
                print("pausedDuringRestTime")
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "RestBackground")!)
                
            } else if isDone {
                print("isDone")
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "DoneBackground")!)
                
            } else {
                print("pausedDuringActiveTime or not paused actually...")
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ActiveBackground")!)
            }
            
        } else if UIDevice.current.orientation.isPortrait {
            print(" UIDevice Portrait")
            if( self.view.frame.height >  self.view.frame.width){
                valWidth = Int(CGFloat(self.view.frame.width-16))
            } else {
                valWidth = Int(CGFloat(self.view.frame.height-16))
            }
            progressIndicatorView?.frame = CGRect(x: CGFloat(Int(self.view.frame.size.height / 2) - Int(valWidth / 2)), y: CGFloat(Int(self.view.frame.size.width / 2) - Int(valWidth / 2)), width: CGFloat(valWidth), height: CGFloat(valWidth))
            progressIndicatorView?.autoresizesSubviews = true
            
            if pausedDuringRestTime {
                print("pausedDuringRestTime")
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "RestBackground")!)

            } else if isDone {
                print("isDone")
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "DoneBackground")!)

            } else {
                print("pausedDuringActiveTime")
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ActiveBackground")!)

            }
        }
    }
    
    func appMovedToBackground() {
        print("App moved to background!")
        
        if running {
            startButton.sendActions(for: .touchUpInside)
        }
//        if (activeTimer != nil) {
//            if(activeTimer?.isValid)!{
//                print("Active timer is running...")
//                for index in 1...valueRounds {
//                    let indexDouble:Double = Double(index)
//
//                    if(index == 1){
//                        let notification = UILocalNotification()
//                        notification.fireDate = NSDate(timeIntervalSinceNow: activeCounter) as Date
//                        notification.alertBody = "Active -- ("+index.description+")"
//                        notification.alertAction = "be awesome!"
//                        notification.soundName = UILocalNotificationDefaultSoundName
//                        notification.userInfo = ["CustomField1": "w00t"]
//                        UIApplication.shared.scheduleLocalNotification(notification)
//                    } else if (index == 2){
//                        let notification = UILocalNotification()
//                        notification.fireDate = NSDate(timeIntervalSinceNow: activeCounter + valueRest) as Date
//                        notification.alertBody = "Rest -- ("+index.description+")"
//                        notification.alertAction = "be awesome!"
//                        notification.soundName = UILocalNotificationDefaultSoundName
//                        notification.userInfo = ["CustomField1": "w00t"]
//                        UIApplication.shared.scheduleLocalNotification(notification)
//                    } else {
//                        if(index % 2 == 0){
//                            let notification = UILocalNotification()
//                            notification.fireDate = NSDate(timeIntervalSinceNow: (indexDouble - 2.0) * (valueActive + valueRest) + (activeCounter + valueRest)) as Date
//                            notification.alertBody = "Rest -- ("+index.description+")"
//                            notification.alertAction = "be awesome!"
//                            notification.soundName = UILocalNotificationDefaultSoundName
//                            notification.userInfo = ["CustomField1": "w00t"]
//                            UIApplication.shared.scheduleLocalNotification(notification)
//                        } else {
//                            let notification = UILocalNotification()
//                            notification.fireDate = NSDate(timeIntervalSinceNow: (indexDouble - 2.0) * valueActive + (indexDouble - 3.0) * valueRest + (activeCounter + valueRest)) as Date
//                            notification.alertBody = "Active -- ("+index.description+")"
//                            notification.alertAction = "be awesome!"
//                            notification.soundName = UILocalNotificationDefaultSoundName
//                            notification.userInfo = ["CustomField1": "w00t"]
//                            UIApplication.shared.scheduleLocalNotification(notification)
//                        }
//                    }
//                }
//            }
//        } else if (restTimer != nil) {
//            print("Rest timer is running...")
//
//        } else {
//            print("No timer is running...")
//        }
//
//        
//        guard let settings = UIApplication.shared.currentUserNotificationSettings else { return }
//        if settings.types == .none {
//            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(ac, animated: true, completion: nil)
//            return
//        }
    }
    
    func updateActiveCounter() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "ActiveBackground")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        if activeCounter >= 0.10 {
            timeValueLabel.text = makeValueReadable(activeCounter)
            activeCounter -= 0.05

            progressValue += 0.05
            progressIndicatorView?.progress = CGFloat(progressValue)/CGFloat(progressTotal)
            
        } else {
            roundsMax -= 1
            if roundsMax > 0{
                restCounter = valueRest
                activeTimer?.invalidate()
                
                
                print("-- isOtherAudioPlaying \(AVAudioSession.sharedInstance().isOtherAudioPlaying)")
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
//                AudioServicesPlaySystemSound(1109)

                restTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateRestCounter), userInfo: nil, repeats: true)
                restTimer?.fire()
            } else {
                UIGraphicsBeginImageContext(self.view.frame.size)
                UIImage(named: "DoneBackground")?.draw(in: self.view.bounds)
                let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                self.view.backgroundColor = UIColor(patternImage: image)
                
                restTimer?.invalidate()
                activeTimer?.invalidate()
                timeValueLabel.text = "Done"
                startButton.setTitle("Start", for: .normal)
                isDone = true
                progressIndicatorView?.progress = 1
            }
        }
    }
    
    func updateRestCounter() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "RestBackground")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        if restCounter >= 0.10 {
            timeValueLabel.text = makeValueReadable(restCounter)
            restCounter -= 0.05
            
            progressValue += 0.05
            progressIndicatorView?.progress = CGFloat(progressValue)/CGFloat(progressTotal)
            
        } else {
            activeCounter = valueActive
            currentRoundsValue += 1

            restTimer?.invalidate()
            
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
//            AudioServicesPlaySystemSound(1075)
            
            activeTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateActiveCounter), userInfo: nil, repeats: true)
            activeTimer?.fire()
        }
    }
    
    @IBAction func backToTableView(_ sender: UIButton){
        restTimer?.invalidate()
        activeTimer?.invalidate()
    }
    
    @IBAction func pressedReset(_ sender: UIButton){
        print("Reset")
        
        activeTimer?.invalidate()
        restTimer?.invalidate()
        
        activeCounter = valueActive
        restCounter = valueRest
        roundsMax = valueRounds
        currentRoundsValue = 0
//        workoutProgress.progress = 0
        progressIndicatorView?.progress = 0
        progressValue = 0.0
        timeValueLabel.text = makeValueReadable(valueActive)
        
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ActiveBackground")!)
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "ActiveBackground")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.green, for: .normal)
        startButton.backgroundColor = UIColor.init(red: 0, green: 144/255, blue: 0, alpha: 0.42)
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.green.cgColor
        pausedDuringRestTime = false
        
        running = false
        isDone = false
    }
    
    @IBAction func pressedStart(_ sender: UIButton){
        print("Start // Pause")
        if isDone == false {
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
        } else {
            resetButton.sendActions(for: .touchUpInside)
            startButton.setTitle("Pause", for: .normal)
            startButton.setTitleColor(UIColor.green, for: .normal)
            startButton.backgroundColor = UIColor.init(red: 0, green: 144/255, blue: 0, alpha: 0.42)
            startButton.layer.borderWidth = 2
            startButton.layer.borderColor = UIColor.green.cgColor
            running = true
            activeTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateActiveCounter), userInfo: nil, repeats: true)
            activeTimer?.fire()
        }
    }
}
