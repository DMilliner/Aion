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
    var isDone:Bool = false
    var pausedDuringRestTime:Bool = false
    var currentRoundsValue: Int = 0

    weak var activeTimer: Timer?
    weak var restTimer: Timer?
    
    var progressIndicatorView: CircularLoaderView?
    var valWidth: Int = 0

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
        
        workoutProgress.progress = 0
        workoutProgress.transform = workoutProgress.transform.scaledBy(x: 1, y: 16)
        workoutProgress.isHidden = true
        
        timeValueLabel.text =  String(format: "%.2f", valueActive)
        timeValueLabel.adjustsFontSizeToFitWidth = true
        timeValueLabel.minimumScaleFactor = 0.5
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
            print(" UIDevice Landscape")
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
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ActiveBackground")!)
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "ActiveBackground")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        if activeCounter >= 0.10 {
            let timeString = String(format: "%.2f", activeCounter)
            timeValueLabel.text = timeString
            activeCounter -= 0.05
            
        } else {
            roundsMax -= 1
            if roundsMax > 0{
                restCounter = valueRest
                activeTimer?.invalidate()
                
//                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//                AudioServicesPlaySystemSound (1257)
                
                restTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateRestCounter), userInfo: nil, repeats: true)
                restTimer?.fire()
            } else {
//                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "DoneBackground")!)
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
                workoutProgress.progress = 100
                progressIndicatorView?.progress = 1
            }
        }
    }
    
    func updateRestCounter() {
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "RestBackground")!)
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "RestBackground")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        if restCounter >= 0.10 {
            let timeString = String(format: "%.2f", restCounter)
            timeValueLabel.text = timeString
            restCounter -= 0.05
            
        } else {
            activeCounter = valueActive
            currentRoundsValue += 1
            print("Rounds \(currentRoundsValue)")

            workoutProgress.progress = Float(Double(currentRoundsValue)/Double(valueRounds))
            progressIndicatorView?.progress = CGFloat(currentRoundsValue)/CGFloat(valueRounds)
            restTimer?.invalidate()
            
//            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//            AudioServicesPlaySystemSound (1258)

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
        activeCounter = valueActive
        restCounter = valueRest
        roundsMax = valueRounds
        currentRoundsValue = 0
        workoutProgress.progress = 0
        progressIndicatorView?.progress = 0

        timeValueLabel.text = valueActive.description
        
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

        activeTimer?.invalidate()
        restTimer?.invalidate()

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
