//
//  AppDelegate.swift
//  VibesFM
//
//  Created by Admin on 21/01/2017.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit
import Harpy
import  UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HarpyDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate{

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.sharedApplication().idleTimerDisabled = false
        
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.currentNotificationCenter().delegate = self
//            
//            let authOptions: UNAuthorizationOptions = [.Alert, .Badge, .Sound]
//            UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions(
//                authOptions,
//                completionHandler: {_, _ in })
//            
//            // For iOS 10 data message (sent via FCM)
//            FIRMessaging.messaging().remoteMessageDelegate = self
//            
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
        
        let center = UNUserNotificationCenter.currentNotificationCenter()
        center.delegate = self
        
        application.registerForRemoteNotifications()
        FIRApp.configure()
        
//        NSNotificationCenter.defaultCenter().addObserver(self,
//        selector: #selector(self.tokenRefreshNotification),
//        name: kFIRInstanceIDTokenRefreshNotification,
//        object: nil)
        
        Harpy.sharedInstance().presentingViewController = self.window!.rootViewController
        Harpy.sharedInstance().delegate = self
        Harpy.sharedInstance().alertType = .Force
        Harpy.sharedInstance().debugEnabled = true
        Harpy.sharedInstance().checkVersion()
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return true
        }
        
        //        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        return true
    }
    
//    func tokenRefreshNotification(notification: NSNotification) {
//        if let refreshedToken = FIRInstanceID.instanceID().token() {
//            print("InstanceID token: \(refreshedToken)")
//        }
//        
//        // Connect to FCM since connection may have failed when attempted before having a token.
//        connectToFcm()
//    }
//    
//    func connectToFcm() {
//        // Won't connect since there is no token
//        guard FIRInstanceID.instanceID().token() != nil else {
//            return
//        }
//        
//        // Disconnect previous FCM connection if it exists.
//        FIRMessaging.messaging().disconnect()
//        
//        FIRMessaging.messaging().connectWithCompletion { (error) in
//            if error != nil {
//                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
//            } else {
//                print("Connected to FCM.")
//            }
//        }
//    }
    
    private func userNotificationCenter(center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        
        
        print("Tapped in notification")
        let actionIdentifier = response.actionIdentifier
        if actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier" || actionIdentifier == "com.apple.UNNotificationDismissActionIdentifier" {
            return;
        }
        let accept = (actionIdentifier == "com.elonchan.yes")
        let decline = (actionIdentifier == "com.elonchan.no")
        let snooze = (actionIdentifier == "com.elonchan.snooze")
        
        repeat {
            if (accept) {
                let title = "Tom is comming now"
                self.addLabel(title, color: UIColor.yellowColor())
                break;
            }
            if (decline) {
                let title = "Tom won't come";
                self.addLabel(title, color: UIColor.redColor())
                break;
            }
            if (snooze) {
                let title = "Tom will snooze for minute"
                self.addLabel(title, color: UIColor.redColor());
                break;
            }
        } while (false);
        // Must be called when finished
        completionHandler();
        
    }
    
    private func addLabel(title: String, color: UIColor) {
        let label = UILabel.init()
        label.backgroundColor = UIColor.redColor()
        label.text = title
        label.sizeToFit()
        label.backgroundColor = color
        let centerX = UIScreen.mainScreen().bounds.width * 0.5
        let centerY = CGFloat(arc4random_uniform(UInt32(UIScreen.mainScreen().bounds.height)))
        label.center = CGPoint(x: centerX, y: centerY)
        self.window!.rootViewController!.view.addSubview(label)
    }
    
    private func userNotificationCenter(center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        // Must be called when finished, when you do not want foreground show, pass [] to the completionHandler()
        completionHandler(UNNotificationPresentationOptions.Alert)
        // completionHandler( UNNotificationPresentationOptions.sound)
        // completionHandler( UNNotificationPresentationOptions.badge)
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        // Only allow portrait (standard behaviour)
        return .Portrait;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (TheGlobalPoolManager.currentRadioViewCon != nil) {
            if (TheGlobalPoolManager.currentRadioViewCon!.radioManager.radio != nil) {
                if (TheGlobalPoolManager.currentRadioViewCon!.radioManager.radio.isPaused()) {
                    print("++++++++++replying again+++++++++")
                    TheGlobalPoolManager.currentRadioViewCon!.radioManager.radio.play()
                }
            }
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Harpy Delegate
    func harpyUserDidCancel() {
    }
    
    func harpyUserDidSkipVersion() {
    }
    
    func harpyDidShowUpdateDialog() {
    }
    
    func harpyUserDidLaunchAppStore() {
    }
    
    func harpyDidDetectNewVersionWithoutAlert(message: String!) {
    }
    
    func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//    }
//    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
//                       fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//        
//        completionHandler(UIBackgroundFetchResult.NewData)
//    }
}

