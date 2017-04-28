//
//  AlarmViewController.swift
//  VibesFM
//
//  Created by Admin on 4/17/17.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit
import  UserNotifications

class AlarmViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var pvMin: UIPickerView!
    @IBOutlet weak var schAlarm: UISwitch!
    
    var hour = 0
    var min = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let center = UNUserNotificationCenter.currentNotificationCenter()
        
        // create actions
        let accept = UNNotificationAction.init(identifier: "com.elonchan.yes",
                                               title: "Accept",
                                               options: UNNotificationActionOptions.Foreground)
        let decline = UNNotificationAction.init(identifier: "com.elonchan.no",
                                                title: "Decline",
                                                options: UNNotificationActionOptions.Destructive)
        let snooze = UNNotificationAction.init(identifier: "com.elonchan.snooze", title: "Snooze", options: UNNotificationActionOptions.Destructive)
        let actions = [ accept, decline, snooze ]
        
        // create a category
        let inviteCategory = UNNotificationCategory(identifier: "com.elonchan.localNotification", actions: actions, intentIdentifiers: [], options: [])
        // registration
        center.setNotificationCategories([ inviteCategory ])
        center.requestAuthorizationWithOptions([.Alert, .Sound], completionHandler: { (granted, error) in
            // Enable or disable features based on authorization.
        })
            // Enable or disable features based on authorization.
                // Do any additional setup after loading the view, typically from a nib.
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let name = "Alarm-View"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let settings = defaults.objectForKey("alarm")
        {
            SharedData.alarmDic = settings as? NSDictionary
            self.pvMin.selectRow(SharedData.alarmDic!["hour"] as! Int, inComponent: 0, animated: true)
            self.pvMin.selectRow(SharedData.alarmDic!["min"] as! Int, inComponent: 2, animated: true)
            self.schAlarm.on = SharedData.alarmDic!["alarm"] as! Bool
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if SharedData.alarmString != nil {
            webView.loadHTMLString(SharedData.alarmString!["text"] as! String, baseURL: nil)
            let url = NSURL(string: SharedData.alarmString!["photo"] as! String)
            
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            imgView.image = UIImage(data: data!)
        }
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // returns the # of rows in each component..
   
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == 0 {
            return 24
        }
        else if component == 1 {
            return 1
        }
        else {
            return 60
        }
        //return 60
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(format: "%02d", row)
        }
        else if component == 1 {
            return ":"
        }
        else {
            return String(format: "%02d", row)
        }
        //return String(format: "%02d", row)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            hour = row
        }
        else if component == 2 {
            min = row
        }
        
        let settings = ["hour":self.pvMin.selectedRowInComponent(0), "min":self.pvMin.selectedRowInComponent(2), "alarm":self.schAlarm.on]
        NSUserDefaults.standardUserDefaults().setObject(settings, forKey: "alarm")
        
        
        let center = UNUserNotificationCenter.currentNotificationCenter()
        center.removeAllPendingNotificationRequests()
       
        if schAlarm.on {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationStringForKey("Elon said:", arguments: nil)
            content.body = NSString.localizedUserNotificationStringForKey("Hello Tom！Get up, let's play with Jerry!", arguments: nil)
            content.sound = UNNotificationSound.defaultSound()
            // NSNumber类型数据
            content.badge = NSNumber(integerLiteral: UIApplication.sharedApplication().applicationIconBadgeNumber + 1);
            content.categoryIdentifier = "com.elonchan.localNotification"
            // Deliver the notification in five seconds.
            /**** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'*/
            
//            let calendar = NSCalendar.autoupdatingCurrentCalendar()
            let dateComps = NSDateComponents()
            dateComps.hour = self.pvMin.selectedRowInComponent(0)
            dateComps.minute = self.pvMin.selectedRowInComponent(2)
//            let notificationDate = calendar.dateFromComponents(dateComps)
            
            
            
            let trigger = UNCalendarNotificationTrigger.init(dateMatchingComponents: dateComps, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            center.addNotificationRequest(request, withCompletionHandler: nil)
        }
            
    }
    
    @IBAction func changedAlarmSCH(sender: AnyObject) {
        let settings = ["hour":self.pvMin.selectedRowInComponent(0), "min":self.pvMin.selectedRowInComponent(2), "alarm":self.schAlarm.on]
        NSUserDefaults.standardUserDefaults().setObject(settings, forKey: "alarm")
        
        let center = UNUserNotificationCenter.currentNotificationCenter()
        center.removeAllPendingNotificationRequests()
        
        if schAlarm.on {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationStringForKey("Alarm:", arguments: nil)
            content.body = NSString.localizedUserNotificationStringForKey("Wake up!", arguments: nil)
            content.sound = UNNotificationSound.defaultSound()
            // NSNumber类型数据
            content.badge = NSNumber(integerLiteral: UIApplication.sharedApplication().applicationIconBadgeNumber + 1);
            content.categoryIdentifier = "com.elonchan.localNotification"
            // Deliver the notification in five seconds.
            /**** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'*/
            
            //            let calendar = NSCalendar.autoupdatingCurrentCalendar()
            let dateComps = NSDateComponents()
            dateComps.hour = self.pvMin.selectedRowInComponent(0)
            dateComps.minute = self.pvMin.selectedRowInComponent(2)
            //            let notificationDate = calendar.dateFromComponents(dateComps)
            
            
            
            let trigger = UNCalendarNotificationTrigger.init(dateMatchingComponents: dateComps, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            center.addNotificationRequest(request, withCompletionHandler: nil)
        }
    }
}
