//
//  TableViewController.swift
//  intervalClock
//
//  Created by David Milliner on 2/22/17.
//  Copyright © 2017 David Milliner. All rights reserved.
//

import UIKit


class TableViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var window: UIWindow?
    
    @IBOutlet weak var tableContentView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    let cellReuseIdentifier = "cell"
    var availableInterval: [String] = []
    var intervalWorkoutList = [IntervalWorkout]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.orange

        tableContentView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableContentView.delegate = self
        tableContentView.dataSource = self
        tableContentView.tableFooterView = UIView()
        tableContentView.backgroundColor = UIColor(white: 1, alpha: 0)
        
        if let data = UserDefaults().object(forKey: "intervalWorkoutList") as? NSData {
            intervalWorkoutList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [IntervalWorkout]
        } else {
            intervalWorkoutList.append(
                IntervalWorkout.init(activeValue: 20,
                                     restValue: 10,
                                     roundsValue: 8,
                                     titleValue: "TABATA"))
            intervalWorkoutList.append(
                IntervalWorkout.init(activeValue: 60,
                                     restValue: 0,
                                     roundsValue: 12,
                                     titleValue: "EMOM"))
            let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
            UserDefaults().set(data, forKey: "intervalWorkoutList")
        }
        
        if let data = UserDefaults().object(forKey: "intervalWorkoutList") as? NSData {
            intervalWorkoutList =  NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [IntervalWorkout]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.title = "Interval Workouts"
        self.reloadProfilePickerContent()
        deselectAllRows()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        
        initView()
    }
    
    func appWillEnterForeground() {
        initView()
        tableContentView.reloadData()
    }
    
    func initView() {
        availableInterval.removeAll()
        for interval in intervalWorkoutList {
            availableInterval.append(interval.titleValue)
        }

    }
    
    func deselectAllRows() {
        if let selectedRows = tableContentView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                tableContentView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    func reloadProfilePickerContent() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableContentView.reloadData()
        })
    }
    
    func makeValueReadable(_ stringActiveValue: String)->String{
        
        let IntValueFromString:Int = Int(stringActiveValue)!
        let valueInMinute = (IntValueFromString % 3720) / 60
        let valueInSecond = (IntValueFromString % 3720) % 60
        if (valueInMinute == 0){
            return valueInSecond.description + "s"
        } else if (valueInSecond == 0){
            return valueInMinute.description + "m "
        } else {
            return valueInMinute.description + "m " + valueInSecond.description + "s"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableInterval.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellAtIndexPath(indexPath)
    }
    
    func cellAtIndexPath(_ indexPath:IndexPath) -> WorkoutTableViewCell {
        let cell:WorkoutTableViewCell = tableContentView.dequeueReusableCell(withIdentifier: "WorkoutCell") as! WorkoutTableViewCell
        
        cell.cellTitle?.text = intervalWorkoutList[(indexPath as NSIndexPath).row].titleValue
        cell.cellSubTitleOne?.text = " " + makeValueReadable(String(format: "%.0f", intervalWorkoutList[(indexPath as NSIndexPath).row].activeValue))
        cell.cellSubTitleTwo?.text = " " + makeValueReadable(String(format: "%.0f", intervalWorkoutList[(indexPath as NSIndexPath).row].restValue))
        cell.cellSubTitleThree?.text = " " + intervalWorkoutList[(indexPath as NSIndexPath).row].roundsValue.description
        
        cell.cellTitle.textColor = UIColor.white
        cell.cellSubTitleOne.textColor = UIColor.white
        cell.cellSubTitleTwo.textColor = UIColor.white
        cell.cellSubTitleThree.textColor = UIColor.white
        
        cell.cellTitle.adjustsFontSizeToFitWidth = true
        cell.cellTitle.minimumScaleFactor = 0.2
        cell.cellTitle.numberOfLines = 0
        
        cell.imageOne.image = UIImage(named: "Hot")
        cell.cellSubTitleOne.adjustsFontSizeToFitWidth = true
        cell.cellSubTitleOne.minimumScaleFactor = 0.2
        cell.cellSubTitleOne.numberOfLines = 0
        
        cell.imageTwo.image = UIImage(named: "Spa")
        cell.cellSubTitleTwo.adjustsFontSizeToFitWidth = true
        cell.cellSubTitleTwo.minimumScaleFactor = 0.2
        cell.cellSubTitleTwo.numberOfLines = 0
        
        cell.imageThree.image = UIImage(named: "InfiniteLoop")
        cell.cellSubTitleThree.adjustsFontSizeToFitWidth = true
        cell.cellSubTitleThree.minimumScaleFactor = 0.2
        cell.cellSubTitleThree.numberOfLines = 0
        
        cell.backgroundColor = UIColor.black
        
        return cell
    }
    
    func switchToViewController(identifier: Int) {
        
        let timerViewController = self.storyboard?.instantiateViewController(withIdentifier: "timerView") as! TimerViewController
        timerViewController.valueActive = intervalWorkoutList[identifier].activeValue
        timerViewController.valueRest = intervalWorkoutList[identifier].restValue
        timerViewController.valueRounds = intervalWorkoutList[identifier].roundsValue
        timerViewController.valueTitle = intervalWorkoutList[identifier].titleValue
        self.navigationController?.setViewControllers([timerViewController], animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        deselectAllRows()
        switchToViewController(identifier: (indexPath as NSIndexPath).row)
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            tableContentView.isEditing = true
            self.navigationItem.leftBarButtonItem!.title = "Done"

        } else {
            tableContentView.isEditing = false
            self.navigationItem.leftBarButtonItem!.title = "Edit"
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let objectToMove = intervalWorkoutList[fromIndexPath.row]
        intervalWorkoutList.remove(at: fromIndexPath.row)
        intervalWorkoutList.insert(objectToMove, at: toIndexPath.row)
        let data = NSKeyedArchiver.archivedData(withRootObject: intervalWorkoutList)
        UserDefaults().set(data, forKey: "intervalWorkoutList")
        UserDefaults().synchronize()
    }
    
    @IBAction func editing(sender: UIButton) {
        self.isEditing = !self.isEditing
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            
            let deleteRowAlert = UIAlertController(title: "Delete Interval Workout", message: "All this will be lost.", preferredStyle: .alert)
            deleteRowAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                self.intervalWorkoutList.remove(at: indexPath.row)
                let data = NSKeyedArchiver.archivedData(withRootObject: self.intervalWorkoutList)
                UserDefaults().set(data, forKey: "intervalWorkoutList")
                UserDefaults().synchronize()
                
                self.initView()
                self.tableContentView.reloadData()}))
            deleteRowAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.initView()
                self.tableContentView.reloadData()}))
            
            self.present(deleteRowAlert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        
        let rename = UITableViewRowAction(style: .default, title: "Rename") { action, index in

            let renameRowAlert = UIAlertController(title: "Rename Interval Workout", message: "Enter a new name", preferredStyle: .alert)
            renameRowAlert.addTextField { (textField) in
                textField.text = self.intervalWorkoutList[indexPath.row].titleValue
            }
            
            renameRowAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                let textField = renameRowAlert.textFields![0]
                if (textField.text?.isEmpty)! {
                    //Either do nothing or let the user know is not clever...
                } else {
                    //Get the profile object selected and reset name
                    self.intervalWorkoutList[indexPath.row].titleValue = (textField.text)!
                    let data = NSKeyedArchiver.archivedData(withRootObject: self.intervalWorkoutList)
                    UserDefaults().set(data, forKey: "intervalWorkoutList")
                    UserDefaults().synchronize()
                    
                    self.initView()
                    self.tableContentView.reloadData()
                }}))
            renameRowAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.initView()
                self.tableContentView.reloadData()}))
            
            self.present(renameRowAlert, animated: true, completion: nil)
            
        }
        rename.backgroundColor = UIColor.orange
        return [delete, rename]
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){}
}
