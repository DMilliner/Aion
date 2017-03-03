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

    var hour:Int = 0
    var minute:Int = 0
    var valueList:[String] = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
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
        startWorkout.layer.borderColor = UIColor.green.cgColor

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.nameField.resignFirstResponder()
//        self.roundsField.resignFirstResponder()

        self.customView.endEditing(true)

        return true
    }
    
    func didChangeText(textField:UITextField) {
        if(!(roundsField.text?.isEmpty)! && !(nameField.text?.isEmpty)!){
            startWorkout.isEnabled = true
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
        return valueList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return valueList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if pickerView.tag == 0 {
                self.hour = row
                print("self.hour -0- \(row)")
            } else if pickerView.tag == 1 {
                self.hour = row
                print("self.hour -1- \(row)")
            }

        case 1:
            if pickerView.tag == 0 {
                self.minute = row
                print("self.minute -0- \(row)")
            } else if pickerView.tag == 1 {
                self.minute = row
                print("self.minute -1- \(row)")
            }

        default:
            print("No component with number \(component)")
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 30
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        if (view != nil) {
//            (view as! UILabel).text = String(format:"%02lu", row)
//            return view!
//        }
//        let columnView = UILabel(frame: CGRect(x: 35, y: 0, width: self.view.frame.size.width/3 - 35, height: 30))
//        columnView.text = String(format:"%02lu", row)
//        columnView.textAlignment = NSTextAlignment.center
//        
//        return columnView
//    }
    
    @IBAction func startCustomizedWorkout(sender: UIButton) {
        startWorkout.isEnabled = false
        
        if(!(roundsField.text?.isEmpty)! && !(nameField.text?.isEmpty)!){
            
            //Save the new workout in the list that will build the tableView
            
            var intervalWorkoutList = [IntervalWorkout]()
            if let data = UserDefaults().object(forKey: "intervalWorkoutList") as? NSData {
                print("previous list")//Maybe not useful ??
                intervalWorkoutList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [IntervalWorkout]
                intervalWorkoutList.append(
                    IntervalWorkout.init(activeValue: 10,
                                         restValue: 10,
                                         roundsValue: Int(roundsField.text!)!,
                                         titleValue: nameField.text!))
                
                let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
                UserDefaults().set(data, forKey: "intervalWorkoutList")
            } else {
                print("create a new list")
                intervalWorkoutList.append(
                    IntervalWorkout.init(activeValue: 10,
                                         restValue: 10,
                                         roundsValue: Int(roundsField.text!)!,
                                         titleValue: nameField.text!))
                
                let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
                UserDefaults().set(data, forKey: "intervalWorkoutList")
            }
            
            let timerViewController = self.storyboard?.instantiateViewController(withIdentifier: "timerView") as! TimerViewController
            timerViewController.valueActive = 10
            timerViewController.valueRest = 10
            timerViewController.valueRounds = Int(roundsField.text!)!
            timerViewController.valueTitle = nameField.text!
            self.navigationController?.setViewControllers([timerViewController], animated: false)
        }
    }
}
