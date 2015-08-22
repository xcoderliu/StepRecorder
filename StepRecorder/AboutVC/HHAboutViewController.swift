//
//  HHAboutViewController.swift
//  pedometer
//
//  Created by 刘智民 on 12/8/15.
//  Copyright (c) 2015年 刘智民. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HHAboutViewController: UIViewController, GADBannerViewDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    var _bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    var _webView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _bannerView.adUnitID = "ca-app-pub-0142633787994349/7609232341";
        _bannerView.rootViewController = self
        _bannerView.loadRequest(GADRequest())
        _bannerView.delegate = self
        _bannerView.center = CGPointMake(self.view.center.x, UIScreen.mainScreen().bounds.height - _bannerView.frame.size.height / 2 - self.tabBarController!.tabBar.bounds.height)
        var sperateLine = UIView(frame: CGRectMake(0, navBar.bounds.height + navBar.frame.origin.y, HHGlobalMethod.kScreenSize.width, 1))
        _webView.frame = CGRectMake(0, navBar.bounds.height + navBar.frame.origin.y + 1, HHGlobalMethod.kScreenSize.width, _bannerView.frame.origin.y - (navBar.bounds.height + navBar.frame.origin.y + 1))
        self.view.addSubview(sperateLine)
        self.view.addSubview(_webView)
        self.view.addSubview(_bannerView)

        let filepath = NSBundle.mainBundle().pathForResource("about", ofType: "html")
        
        if filepath != nil {
           _webView.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: filepath!)!))
        }
        else {
            let url = NSBundle.mainBundle().URLForResource("client_about", withExtension:"html")
            _webView.loadRequest(NSURLRequest(URL: url!))
        }
        
        _webView.backgroundColor = UIColor.whiteColor()
        navBarItem.title = HHGlobalMethod.LocalizedString("about")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adViewDidReceiveAd(view: GADBannerView!) {
        println("接收到了广告")
    }
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        println("接收广告发生错误:\(error.localizedDescription)")
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
