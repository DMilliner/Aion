//
//  CustomWorkoutViewController.swift
//  intervalClock
//
//  Created by David Milliner on 2/23/17.
//  Copyright © 2017 David Milliner. All rights reserved.
//

import UIKit

class CustomWorkoutViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
//    @IBOutlet weak var activeTimeField: UITextField!
//    @IBOutlet weak var restTimeField: UITextField!
    @IBOutlet weak var roundsField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var activePicker: UIPickerView!
    @IBOutlet weak var restPicker: UIPickerView!

    @IBOutlet weak var startWorkout: UIButton!
    @IBOutlet weak var customView: UIScrollView!

    var activeTimeInMinute:Int = 0
    var restTimeInMinute:Int = 0
    var activeTimeInSecond:Int = 0
    var restTimeInSecond:Int = 0
    
    
    var valueSecond:[String] = ["00", "01", "02", "03", "04", "05", "10", "15","20",
                                "25", "30", "40", "45", "50", "55", "60"]
    
    var valueMinute:[String] = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
                                "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
                                "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
                                "30", "31", "32", "33", "34", "35", "36", "37", "38", "39",
                                "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
                                "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.orange

        startWorkout.isEnabled = false
        nameField.delegate = self
        roundsField.delegate = self
        
        activePicker.dataSource = self
        activePicker.delegate = self
        activePicker.tag = 0
        
        restPicker.dataSource = self
        restPicker.delegate = self
        restPicker.tag = 1
        
        roundsField.addTarget(self, action: #selector(CustomWorkoutViewController.didChangeText), for: .editingChanged)
        nameField.addTarget(self, action: #selector(CustomWorkoutViewController.didChangeText), for: .editingChanged)
        startWorkout.layer.borderWidth = 2
        startWorkout.layer.borderColor = UIColor.red.cgColor
        startWorkout.backgroundColor = UIColor(red: 144/255, green: 0, blue: 0, alpha: 0.42)
        startWorkout.setTitleColor(UIColor.red, for: .normal)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomWorkoutViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.tintColor = UIColor.orange
        
        let customPreviousView: UIButton = UIButton(type: UIButtonType.custom)
        customPreviousView.setImage(UIImage(named: "previous"), for: UIControlState.normal)
        customPreviousView.addTarget(self, action:  #selector(CustomWorkoutViewController.textFieldPrevious), for: UIControlEvents.touchUpInside)
        customPreviousView.frame = CGRect(x: 0, y: 0, width: 31, height: 31)
        customPreviousView.tintColor = UIColor.orange

        let customNextView: UIButton = UIButton(type: UIButtonType.custom)
        customNextView.setImage(UIImage(named: "next"), for: UIControlState.normal)
        customNextView.addTarget(self, action:  #selector(CustomWorkoutViewController.textFieldNext), for: UIControlEvents.touchUpInside)
        customNextView.frame = CGRect(x: 0, y: 0, width: 31, height: 31)
        
        let previousButton = UIBarButtonItem(customView: customPreviousView)
        let nextButton = UIBarButtonItem(customView: customNextView)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                          target: nil,
                                          action: nil)
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: UIBarButtonItemStyle.done,
                                         target: nil,
                                         action:  #selector(CustomWorkoutViewController.startCustomizedWorkout(sender:)))
        
        toolBar.setItems([previousButton, nextButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        roundsField.delegate = self
        nameField.delegate = self
        
        roundsField.inputAccessoryView = toolBar
        nameField.inputAccessoryView = toolBar
    }
    
    func textFieldNext(){
        if(nameField.isEditing){
            roundsField.becomeFirstResponder()
        } else {
            dismissKeyboard()
        }
    }
    
    func textFieldPrevious(){
        if(roundsField.isEditing){
            nameField.becomeFirstResponder()
        } else {
            dismissKeyboard()
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func didChangeText(textField:UITextField) {
        if(!(roundsField.text?.isEmpty)! && !(nameField.text?.isEmpty)!){
            startWorkout.isEnabled = true
            startWorkout.layer.borderColor = UIColor.green.cgColor
            startWorkout.backgroundColor = UIColor(red: 0, green: 144/255, blue: 0, alpha: 0.42)
            startWorkout.setTitleColor(UIColor.green, for: .normal)
        } else {
            startWorkout.isEnabled = false
            startWorkout.layer.borderColor = UIColor.red.cgColor
            startWorkout.backgroundColor = UIColor(red: 144/255, green: 0, blue: 0, alpha: 0.42)
            startWorkout.setTitleColor(UIColor.red, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return valueMinute.count
        case 1:
            return valueSecond.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return valueMinute[row]
        case 1:
            return valueSecond[row]
        default:
            return "???"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        view.endEditing(true)
        
        switch component {
        case 0:
            if pickerView.tag == 0 {
                self.activeTimeInMinute = Int(valueMinute[row])!
            } else if pickerView.tag == 1 {
                self.restTimeInMinute = Int(valueMinute[row])!
            }

        case 1:
            if pickerView.tag == 0 {
                self.activeTimeInSecond = Int(valueSecond[row])!
            } else if pickerView.tag == 1 {
                self.restTimeInSecond = Int(valueSecond[row])!
            }
        default: break

        }
    }
    
    @IBAction func startCustomizedWorkout(sender: UIButton) {
        
        if(!(roundsField.text?.isEmpty)!
            && !(nameField.text?.isEmpty)!
            && (Int(activeTimeInMinute * 60) + activeTimeInSecond) + (Int(restTimeInMinute * 60) + restTimeInSecond) != 0){
            
            //Save the new workout in the list that will build the tableView
            
            var intervalWorkoutList = [IntervalWorkout]()
            if let data = UserDefaults().object(forKey: "intervalWorkoutList") as? NSData {
                intervalWorkoutList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [IntervalWorkout]
                intervalWorkoutList.append(
                    IntervalWorkout.init(activeValue: Double(Int(Int(activeTimeInMinute * 60) + activeTimeInSecond)),
                                         restValue: Double(Int(Int(restTimeInMinute * 60) + restTimeInSecond)),
                                         roundsValue: Int(roundsField.text!)!,
                                         titleValue: nameField.text!))
                
                let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
                UserDefaults().set(data, forKey: "intervalWorkoutList")
            } else {
                intervalWorkoutList.append(
                    IntervalWorkout.init(activeValue: Double(Int(Int(activeTimeInMinute * 60) + activeTimeInSecond)),
                                         restValue: Double(Int(Int(restTimeInMinute * 60) + restTimeInSecond)),
                                         roundsValue: Int(roundsField.text!)!,
                                         titleValue: nameField.text!))
                
                let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
                UserDefaults().set(data, forKey: "intervalWorkoutList")
            }
            
            let timerViewController = self.storyboard?.instantiateViewController(withIdentifier: "timerView") as! TimerViewController
            timerViewController.valueActive = Double(Int(Int(activeTimeInMinute * 60) + activeTimeInSecond))
            timerViewController.valueRest = Double(Int(Int(restTimeInMinute * 60) + restTimeInSecond))
            timerViewController.valueRounds = Int(roundsField.text!)!
            timerViewController.valueTitle = nameField.text!
            self.navigationController?.setViewControllers([timerViewController], animated: true)
        } else {
            view.endEditing(true)
            let alert = UIAlertController(title: "Erreur", message: "You need to set your active time interval to start.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
