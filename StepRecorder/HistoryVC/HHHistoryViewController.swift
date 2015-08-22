//
//  HHHistoryViewController.swift
//  pedometer
//
//  Created by 刘智民 on 11/8/15.
//  Copyright (c) 2015年 刘智民. All rights reserved.
//

import UIKit
import HealthKit

class HHHistoryViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var _tableview: UITableView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    private var stepsOut = [HKQuantitySample]()
    private var dataSource = Dictionary<String,[Int]>()
    private var stepdays = [String]() //为了保证有序
    
    // MARK: - Formatters
    lazy var dateformatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        return formatter;
    }()
    
    lazy var ignoredateformatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .NoStyle
        return formatter;
        }()
    
    lazy var ignoretimeformatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .NoStyle
        formatter.dateStyle = .MediumStyle
        return formatter;
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        _tableview.delegate = self
        _tableview.dataSource = self
        _tableview.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "historystepsCell")
        _tableview.tableFooterView = UIView(frame: CGRectZero)
        navBarItem.title = HHGlobalMethod.LocalizedString("history_steps")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.readStepsData()
    }
    
    // MARK: - Private
    
    func readStepsData()
    {
        HHRootViewController.gHealth.readStepsWorksout(0, completion: { (results, error) -> Void in
            if( error != nil ) {
                HHGlobalMethod.showAlert("read_failed", message: error.localizedDescription, time: 2)
                return;
            }
            
            //Kkeep workouts and refresh tableview in main thread
            self.stepsOut = results as! [HKQuantitySample]
            self.dataSource.removeAll(keepCapacity: false)
            
            //数据分组化处理
            self.stepdays.removeAll(keepCapacity: false)
            
            for walk in self.stepsOut {
                var day = self.ignoretimeformatter.stringFromDate(walk.startDate)
                if !contains(self.stepdays, day) {//得到所有日期的key
                    self.stepdays.append(day)
                }
            }
            
            for day in self.stepdays {
                var daywalksIndex = [Int]()
                var index:Int = 0
                for walk in self.stepsOut {
                    var theday = self.ignoretimeformatter.stringFromDate(walk.startDate)
                    if theday == day {
                        daywalksIndex.append(index)
                    }
                    index = index + 1
                }
                self.dataSource.updateValue(daywalksIndex, forKey: day)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self._tableview.reloadData()
            })
        })
    }
    
    func minutesFormat(minutes:Int) ->String
    {
        var nHours: Int = minutes / 60
        var nMinutes: Int = minutes % 60
        
        if nHours <= 0 {
            return String(format: "%d%@", nMinutes, HHGlobalMethod.LocalizedString("minutes")!)
        }
        
        if nHours > 0 && nMinutes == 0 {
            return String(format: "%d%@", nHours, HHGlobalMethod.LocalizedString("hours")!)
        }
        
        return String(format: "%d%@ %d%@", nHours, HHGlobalMethod.LocalizedString("hours")!, nMinutes, HHGlobalMethod.LocalizedString("minutes")!)
    }
    
    //MARK: - tableview delegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var daywalksIndex = dataSource[stepdays[section]]
        return daywalksIndex!.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "historystepsCell")
        var daywalksIndex = dataSource[stepdays[indexPath.section]]
        var index = daywalksIndex?[indexPath.row]
        let workout  = stepsOut[index!]
        var steps = workout.quantity.doubleValueForUnit(HKUnit.countUnit())
        cell.textLabel?.text = String(format: "%d %@", Int(steps), HHGlobalMethod.LocalizedString("steps")!)
        let endDate = workout.endDate
        let startDate = workout.startDate
        let duration = endDate.timeIntervalSinceDate(startDate)
        cell.detailTextLabel?.text = self.minutesFormat(Int(duration / 60))
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stepdays[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //remove the color
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var daywalksIndex = dataSource[stepdays[indexPath.section]]
        var index = daywalksIndex?[indexPath.row]
        let workout  = stepsOut[index!]
        HHRootViewController.gHealth.removeSample(workout, completion: { (result, error) -> Void in
            if result {
                self.readStepsData()
            }
            else {
                HHGlobalMethod.showAlert("delete_failed", message: error.localizedDescription, time: 2)
            }
        })
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 28
        }
        return 20
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return HHGlobalMethod.LocalizedString("delete")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
