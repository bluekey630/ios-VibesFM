//
//  GlobalPool.swift
//  Radio
//
//  Created by Admin on 11/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMobileAds

let TheGlobalPoolManager = GlobalPool.sharedInstance

class GlobalPool: NSObject, GADInterstitialDelegate {
    static let sharedInstance = GlobalPool()
    
    var interstitialAd : GADInterstitial!
    
    var deviceToken: String = Constants.DeviceInfo.DefaultDeviceToken
    var deviceID: String = Constants.DeviceInfo.DefaultDeviceToken
    
    var rootViewCon: ViewController? = nil
    
    var currentRadioViewCon: ViewController? = nil
    
    var curCountryCode: String = ""
    
    var nPlayedRadioCnt: Int = 0
    
    override init() {
        super.init()
        
        geteUniqueID()
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName as! String)
            print("Font Names = [\(names)]")
        }
    }

    func increasePlayingCnt() {
        if (nPlayedRadioCnt == 0) {
            self.showInterstitalAD()
        }
        
        if (nPlayedRadioCnt >= Constants.AdMob.Interstital_Interval) {
            nPlayedRadioCnt = 1
            self.showInterstitalAD()
        }
        
        nPlayedRadioCnt += 1
    }
    
    func loadIntersitialAD() {
        self.interstitialAd = GADInterstitial(adUnitID: Constants.AdMob.Interstitial)
        let request = GADRequest()
        request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        self.interstitialAd.loadRequest(request)
        self.interstitialAd = reloadInterstitialAd()
    }
    
    func showInterstitalAD() {
        if self.interstitialAd.isReady {
            self.interstitialAd.presentFromRootViewController(UIApplication.topViewController()!)
        }
    }
    
    func reloadInterstitialAd() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: Constants.AdMob.Interstitial)
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        self.interstitialAd = reloadInterstitialAd()
    }
    
    func getGetAllCountryCodes() -> [String] {
        var countries = NSLocale.ISOCountryCodes().flatMap { countryCode in
            return countryCode//locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)
        }
        countries.sortInPlace()
        
        return countries
    }
    
    func getCountryName(countryCode: String) -> String {
        let locale = NSLocale.currentLocale()
        let countryName = locale.displayNameForKey(NSLocaleCountryCode, value: countryCode)

        return countryName!
    }
    
    func getCurrentCountryCode() {
        let currentLocale = NSLocale.currentLocale()
        let countryCode = currentLocale.objectForKey(NSLocaleCountryCode) as? String
        
        curCountryCode = Constants.CountryCode//countryCode!
    }
    
    func geteUniqueID() {
        var venderID = NSUserDefaults.standardUserDefaults().stringForKey("venderid")
        
        if (venderID == "" || venderID == nil) {
            venderID = UIDevice.currentDevice().identifierForVendor!.UUIDString
            
            NSUserDefaults.standardUserDefaults().setObject(venderID, forKey: "venderid")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        deviceID = venderID!.stringByReplacingOccurrencesOfString("-", withString: "")
        NSLog("vender id \(deviceID)")
    }

    func makeSecondsTime(nTime: Int) -> String {
        var bufTime = nTime
        if bufTime < 0 {
            bufTime = 0
        }
        let nMin = bufTime / 60
        let nSec = bufTime - nMin * 60
        
        let formattedTime = String(format: "%02d:%02d", nMin, nSec)
        return formattedTime
    }
    
    func checkPushNotificationPermission() -> Bool {
        let notificationType = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
        if notificationType == UIUserNotificationType.None {
            // Push notifications are disabled in setting by user.
            return false
        }else{
            // Push notifications are enabled in setting by user.
            return true
        }
        /*
        let bIsRegistered = UIApplication.sharedApplication().isRegisteredForRemoteNotifications()
        return bIsRegistered
         */
    }

 }
