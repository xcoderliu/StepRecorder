//
//  HHAddStepsViewController.swift
//  pedometer
//
//  Created by 刘智民 on 7/8/15.
//  Copyright (c) 2015年 刘智民. All rights reserved.
//

import UIKit

public enum pickerType:Int {
    case date = 0, time = 1
}

class HHAddStepsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

    //常量
    let kStepsTextFiledTag: Int = 0
    let kLeftInset: CGFloat = 20.0
    let kRightInset: CGFloat = 10.0
    let kSecondsInMinute: CGFloat = 60.0
    let kTipLabelWidth: CGFloat = 80
    let kMaxSteps = 10000
    
    
    //变量
    @IBOutlet weak var _tableview: UITableView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    private let img_pedometer: UIImageView = UIImageView(image: UIImage(named: "img_pedometer"))
    private var nSteps: Int = 0
    private var nDurations: Int = 0
    private let steps_input: UITextField = UITextField()
    private let lab_duration: UILabel = UILabel()
    private let lab_endDate: UILabel = UILabel()
    private let date_picker = UIDatePicker()
    private let time_picker = UIPickerView()
    private var canBecomefirstresponder: Bool = false
    private var _Pickertype: pickerType = pickerType.date
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _tableview.delegate = self
        _tableview.dataSource = self
        _tableview.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "AddStepsCell")
        _tableview.tableFooterView = UIView(frame: CGRectZero)
        
        time_picker.backgroundColor = UIColor.whiteColor()
        date_picker.backgroundColor = UIColor.whiteColor()
        time_picker.delegate = self
        time_picker.dataSource = self
        date_picker.addTarget(self, action: Selector("datePickerValueChanged"), forControlEvents: .ValueChanged)
        
        canBecomefirstresponder = false
        
        navBarItem.title = HHGlobalMethod.LocalizedString("add_steps")
        
        self.RegisterNotification()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reSetDatas()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func RegisterNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showSaveStepsResult:"), name: "healthkitSaveStepsResultNotifacation", object: nil)
    }
    
    //MARK: - tableview delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        else if section == 1 {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 92 + self.img_pedometer.frame.size.height
        }
        else {
            return 43.0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 43.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddStepsCell", forIndexPath: indexPath) as! UITableViewCell
        
        for temp in cell.subviews {
            if temp is UILabel || temp is UIButton {
                temp.removeFromSuperview()
            }
        }
        
        cell.selectionStyle = .Blue
        cell.bounds = CGRectMake(0, 0, HHGlobalMethod.kScreenSize.width, cell.bounds.size.height)
        
        if indexPath.section == 0 { //输入步数
            if indexPath.row == 0 {
                //text filed
                steps_input.frame = CGRectMake(kLeftInset, 0, cell.bounds.width - kLeftInset - kRightInset, cell.bounds.height)
                steps_input.keyboardType = UIKeyboardType.NumberPad
                steps_input.tag = kStepsTextFiledTag
                steps_input.delegate = self
                steps_input.textAlignment = .Right
                steps_input.placeholder = HHGlobalMethod.LocalizedString("step_input")
                
                //label
                var tip_input: UILabel = UILabel(frame: CGRectMake(kLeftInset, 0, kTipLabelWidth, cell.bounds.height))
                tip_input.textAlignment = .Left
                tip_input.text = HHGlobalMethod.LocalizedString("step_num")
                tip_input.textColor = UIColor ( red: 0.6642, green: 0.6642, blue: 0.6642, alpha: 1.0 )
                
                cell.addSubview(steps_input)
                cell.addSubview(tip_input)
            }
            else if indexPath.row == 1  { //运动时长
                lab_duration.frame = CGRectMake(kLeftInset, 0, cell.bounds.size.width - kLeftInset - kRightInset, cell.bounds.size.height)
                lab_duration.textAlignment = .Right
                lab_duration.adjustsFontSizeToFitWidth = true
                
                var tip_duration: UILabel = UILabel(frame: CGRectMake(kLeftInset, 0, kTipLabelWidth + 20, cell.bounds.height))
                tip_duration.textAlignment = .Left
                tip_duration.text = HHGlobalMethod.LocalizedString("exercise_duration")
                tip_duration.adjustsFontSizeToFitWidth = true
                tip_duration.textColor = UIColor ( red: 0.6642, green: 0.6642, blue: 0.6642, alpha: 1.0 )
                
                cell.addSubview(lab_duration)
                cell.addSubview(tip_duration)
                
            }
            else if indexPath.row == 2 { //输入运动结束时间
                var date: NSDate = NSDate()
                var dateFormat: NSDateFormatter = NSDateFormatter()
                dateFormat.timeStyle = .ShortStyle
                dateFormat.dateStyle = .MediumStyle
                lab_endDate.text = dateFormat.stringFromDate(date)
                lab_endDate.frame = CGRectMake(kLeftInset, 0, cell.bounds.size.width - kLeftInset - kRightInset, cell.bounds.size.height)
                lab_endDate.textAlignment = .Right
                lab_endDate.adjustsFontSizeToFitWidth = true
                
                var tip_endTime: UILabel = UILabel(frame: CGRectMake(kLeftInset, 0, kTipLabelWidth, cell.bounds.height))
                tip_endTime.textAlignment = .Left
                tip_endTime.text = HHGlobalMethod.LocalizedString("end_time")
                tip_endTime.textColor = UIColor ( red: 0.6642, green: 0.6642, blue: 0.6642, alpha: 1.0 )
                
                cell.addSubview(lab_endDate)
                cell.addSubview(tip_endTime)
            }
            
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 { //添加按钮
                var btn_add: UIButton = UIButton(frame: cell.bounds)
                btn_add.setTitle(HHGlobalMethod.LocalizedString("add"), forState: UIControlState.Normal)
                btn_add.setTitleColor(UIColor ( red: 0.9922, green: 0.189, blue: 0.4143, alpha: 1.0 ), forState: UIControlState.Normal)
                btn_add.addTarget(self, action: Selector("addDown:"), forControlEvents: .TouchUpInside)
                cell.addSubview(btn_add)
            }
        }
        return cell
    }
    
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //remove the color
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //response to the select
        if indexPath.section == 0 {
            self.scrollTobottom()
            switch(indexPath.row) {
                case 0:
                    steps_input.becomeFirstResponder()
                    break;
                case 1:
                    canBecomefirstresponder = true
                    if self.isFirstResponder()
                    {
                        self.resignFirstResponder()
                    }
                    _Pickertype = pickerType.time
                    self.becomeFirstResponder()
                    canBecomefirstresponder = false
                    time_picker.selectRow(0, inComponent: 0, animated: false)
                    time_picker.selectRow(2, inComponent: 1, animated: false)
                    break;
                case 2:
                    canBecomefirstresponder = true
                    _Pickertype = pickerType.date
                    if self.isFirstResponder()
                    {
                        self.resignFirstResponder()
                    }
                    self.becomeFirstResponder()
                    canBecomefirstresponder = false
                    break;
                default:
                    break;
            }
        }
        else if indexPath.section == 1 {
            return
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectZero)
        if section == 0 {
            view.frame = CGRectMake(0, 0, HHGlobalMethod.kScreenSize.width, 92 + self.img_pedometer.frame.size.height)
            var lab_inputTip :UILabel = UILabel(frame: CGRectMake(0, 27, view.frame.width, 15))
            lab_inputTip.text = HHGlobalMethod.LocalizedString("steps_num_input")
            lab_inputTip.textAlignment = NSTextAlignment.Center
            lab_inputTip.font = UIFont.boldSystemFontOfSize(17)
            lab_inputTip.adjustsFontSizeToFitWidth = true
            view.addSubview(lab_inputTip)
            img_pedometer.frame = CGRectMake((view.frame.size.width - img_pedometer.frame.size.width) / 2, 69, img_pedometer.frame.size.width, img_pedometer.frame.size.height)
            view.addSubview(img_pedometer)
        }
        //add a gesture to handle the tap
        var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        view.addGestureRecognizer(tapGesture)
        return view
    }
    
    //MARK: - gesture
    func handleTap(tap: UITapGestureRecognizer) ->Void {
        self.resignAllFirstResponder()
    }
    
    //MARK: - UIbutton
    
    func addDown(button: UIButton) {
        if nSteps <= 0 || nDurations <= 0 {
            HHGlobalMethod.showAlert("", message: "please_correct_data", time: 2)
            self.reSetDatas()
        }
        else{
            if nSteps >= kMaxSteps {
                HHGlobalMethod.showAlert("", message: "please_intput_less_than", time: 2)
            }
            else{
                HHRootViewController.gHealth.saveStepsSample(Double(nSteps), endDate: date_picker.date, duration: nDurations ,completion: { (success, error ) -> Void in
                    if  success {
                        HHGlobalMethod.showAlert("add_success", message: "", time: 1)
                    }
                    else {
                        if error.code == 4 {//认证失败
                             HHGlobalMethod.showAlert("add_failed", message: HHGlobalMethod.LocalizedString("authoried_tip")!, time: 2)
                        }
                        else {
                            HHGlobalMethod.showAlert("add_failed", message: error.localizedDescription, time: 2)
                        }
                    }
                })
            }
            self.reSetDatas()
        }
    }
    
    // MARK: - UITextFiled delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == nil || textField.text == ""
        {
            return
        }
        var temp = textField.text.toInt()
        if temp != nil
        {
           nSteps = temp!
        }
        else{
            nSteps = 0
            steps_input.text = ""
            HHGlobalMethod.showAlert("", message: "input_an_integer", time: 1.5)
        }
    }
    
    //MARK: - Picker view Delegates and data sources
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0
        {
            return 13
        }
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if component == 0
        {
            return String(format: "%d%@", row,HHGlobalMethod.LocalizedString("hours")!)
        }
        else if component == 1
        {
            return String(format: "%d%@", row * 15,HHGlobalMethod.LocalizedString("minutes")!)
        }
        return " "
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateDurationlabel()
    }
    
    // MARK: - Picker method
    
    func datePickerValueChanged( ) {
        updateDateTimeLabel()
    }
    
    func updateDateTimeLabel() {
        var date: NSDate = date_picker.date
        var dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.timeStyle = .ShortStyle
        dateFormat.dateStyle = .MediumStyle
        lab_endDate.text = dateFormat.stringFromDate(date)
    }
    
    func updateDurationlabel() {
        var nHours = time_picker.selectedRowInComponent(0)
        var nMinutes = time_picker.selectedRowInComponent(1)
        nDurations = nHours * 60 + nMinutes * 15
        if nHours <= 0
        {
            lab_duration.text = String(format: "%d%@", nMinutes * 15,HHGlobalMethod.LocalizedString("minutes")!)
        }
        else{
            lab_duration.text = String(format: "%d%@ %d%@", nHours, HHGlobalMethod.LocalizedString("hours")!, nMinutes * 15,HHGlobalMethod.LocalizedString("minutes")!)
        }
    }
    
    // MARK: - internal override
    
    internal override func canBecomeFirstResponder() -> Bool {
        return canBecomefirstresponder
    }
    
    internal override var inputView: UIView! {
        get {
            if(_Pickertype == pickerType.date) {
                return date_picker
            }
            else if(_Pickertype == pickerType.time) {
                return time_picker
            }
            return date_picker
        }
    }
    
    // MARK: - Private
    
    func reSetDatas() {
        steps_input.text = "1024"
        lab_duration.text = String(format: "30%@",HHGlobalMethod.LocalizedString("minutes")!)
        nSteps = 1024
        nDurations = 30
        date_picker.date = NSDate()
        self.resignAllFirstResponder()
        _tableview.reloadData()
    }
    
    func scrollTobottom() {
        var ipath: NSIndexPath = NSIndexPath(forRow: 2, inSection: 0) //sport time setting
        _tableview.scrollToRowAtIndexPath(ipath, atScrollPosition: .Top, animated: true)
    }
    
    func resignAllFirstResponder() {
        if steps_input.isFirstResponder()
        {
            steps_input.resignFirstResponder()
        }
        if self.isFirstResponder()
        {
            self.resignFirstResponder()
        }
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
