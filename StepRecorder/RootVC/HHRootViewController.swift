//
//  HHRootViewController.swift
//  pedometer
//
//  Created by 刘智民 on 7/8/15.
//  Copyright (c) 2015年 刘智民. All rights reserved.
//

import UIKit

class HHRootViewController: UITabBarController {
    //成员变量
    @IBOutlet weak private var _myTab: UITabBar!
    private var tab_addWorkout: UITabBarItem!
    private var tab_history: UITabBarItem!
    private var tab_about: UITabBarItem!
    static var gHealth :HealthManager = HealthManager()
    let aboutUrl = "http://steprecorder.hihex.com/about.html"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Get uitbarbarItem
        tab_addWorkout = _myTab.items![0] as! UITabBarItem
        tab_history = _myTab.items![1] as! UITabBarItem
        tab_about = _myTab.items![2] as! UITabBarItem
        
        //Ret UI
        _myTab.tintColor = UIColor ( red: 0.9922, green: 0.189, blue: 0.4143, alpha: 1.0 )
        tab_addWorkout.selectedImage = UIImage(named: "tab_select_add_workout")?.imageWithRenderingMode(.AlwaysOriginal)
        tab_addWorkout.title = HHGlobalMethod.LocalizedString("add_steps")
        tab_history.selectedImage = UIImage(named: "tab_select_history")?.imageWithRenderingMode(.AlwaysOriginal)
        tab_history.title = HHGlobalMethod.LocalizedString("history_steps")
        tab_about.selectedImage = UIImage(named: "tab_select_about")?.imageWithRenderingMode(.AlwaysOriginal)
        tab_about.title = HHGlobalMethod.LocalizedString("about")
        HHRootViewController.gHealth.authorizeHealthKit {(success, error) -> Void in}
        
        //Add Google analytics
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "RootViewController")
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        //Update about web
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.UpdateaboutWeb()
        })
    }
    
    func UpdateaboutWeb() ->Void
    {
        let url = NSURL(string: aboutUrl)
        let webData = NSData(contentsOfURL: url!)
        if webData != nil {
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)
            let filePath = String(paths[0] as! NSString)
            webData?.writeToFile(filePath, atomically: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
