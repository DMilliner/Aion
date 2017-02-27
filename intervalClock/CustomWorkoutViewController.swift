//
//  CustomWorkoutViewController.swift
//  intervalClock
//
//  Created by David Milliner on 2/23/17.
//  Copyright © 2017 David Milliner. All rights reserved.
//

import UIKit

class CustomWorkoutViewController: UIViewController, UINavigationControllerDelegate {

    
    @IBOutlet weak var activeTimeField: UITextField!
    @IBOutlet weak var restTimeField: UITextField!
    @IBOutlet weak var roundsField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var startWorkout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startWorkout.isEnabled = false

        activeTimeField.addTarget(self, action: #selector(CustomWorkoutViewController.didChangeText), for: .editingChanged)
        restTimeField.addTarget(self, action: #selector(CustomWorkoutViewController.didChangeText), for: .editingChanged)
        roundsField.addTarget(self, action: #selector(CustomWorkoutViewController.didChangeText), for: .editingChanged)
        nameField.addTarget(self, action: #selector(CustomWorkoutViewController.didChangeText), for: .editingChanged)
        

    }
    
    func didChangeText(textField:UITextField) {
        startWorkout.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startCustomizedWorkout(sender: UIButton) {
        startWorkout.isEnabled = false

        //Save the new workout in the list that will build the tableView
        
        var intervalWorkoutList = [IntervalWorkout]()
        if let data = UserDefaults().object(forKey: "intervalWorkoutList") as? NSData {
            print("previous list")//Maybe not useful ??
            intervalWorkoutList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [IntervalWorkout]
            intervalWorkoutList.append(
                IntervalWorkout.init(activeValue: Double(activeTimeField.text!)!,
                                     restValue: Double(restTimeField.text!)!,
                                     roundsValue: Int(roundsField.text!)!,
                                     titleValue: nameField.text!))
            
            let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
            UserDefaults().set(data, forKey: "intervalWorkoutList")
        } else {
            print("create a new list")
            intervalWorkoutList.append(
                IntervalWorkout.init(activeValue: Double(activeTimeField.text!)!,
                                     restValue: Double(restTimeField.text!)!,
                                     roundsValue: Int(roundsField.text!)!,
                                     titleValue: nameField.text!))

            let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
            UserDefaults().set(data, forKey: "intervalWorkoutList")
        }
        
        let timerViewController = self.storyboard?.instantiateViewController(withIdentifier: "timerView") as! TimerViewController
        timerViewController.valueActive = Double(activeTimeField.text!)!
        timerViewController.valueRest = Double(restTimeField.text!)!
        timerViewController.valueRounds = Int(roundsField.text!)!
        timerViewController.valueTitle = nameField.text!
        self.navigationController?.setViewControllers([timerViewController], animated: false)
        
    }
}
