//
//  HHGlobalMethod.swift
//  pedometer
//
//  Created by 刘智民 on 8/8/15.
//  Copyright (c) 2015年 刘智民. All rights reserved.
//

import UIKit

class HHGlobalMethod: NSObject {
    static var kScreenSize: CGSize = UIScreen.mainScreen().bounds.size
    static func LocalizedString(keyString: String) ->String?
    {
        return NSBundle.mainBundle().localizedStringForKey(keyString, value: keyString, table: nil)
    }
    static func showAlert(title: String, message: String, time: Double)
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var alertTemp: UIAlertView = UIAlertView(title: self.LocalizedString(title), message: self.LocalizedString(message), delegate: nil, cancelButtonTitle: nil)
            alertTemp.show()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,Int64(time * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                alertTemp.dismissWithClickedButtonIndex(0, animated: true)
            }
        })
    }
}
