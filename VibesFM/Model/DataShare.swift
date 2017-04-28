//
//  DataShare.swift
//  VibesFM
//
//  Created by Admin on 4/13/17.
//  Copyright © 2017 Yury. All rights reserved.
//

import Foundation
let SharedData = DataShare.sharedInstance

class DataShare : NSObject {
    static let sharedInstance = DataShare()
    
    var menuArray:NSArray?
    var contactString:String?
    var faqString:String?
    var imprintString:String?
    var termsPolicyString:String?
    var alarmString:NSDictionary?
    var changeDesignString:String?
    var templateID = 0
    var alarmDic:NSDictionary?
    var delegate:NSObject?
    var maxTime:Int = 0
    var valTime:Int = 0
    var stationState:Int = 0
    var state = 0
    var settingsDic:NSDictionary?
    var isPremiumUser = false
    var premiumshortnotice:String?
    override init() {
        super.init()
    }
    
    
}
/*
 
 + (void)trackingEvents:(NSDictionary*)eventsDict {
 id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
 [tracker send:eventsDict];
 
 //    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"       // Event category (required)
 //                                                          action:@"button_press"    // Event action (required)
 //                                                           label:@"play"            // Event label
 //                                                           value:nil] build]];      // Event value
 }
 
 
 + (void)trackingScreenView:(NSString*)screenName {
 //    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
 //    [tracker set:kGAIScreenName value:screenName];
 //    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
 
 id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
 [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"page visit"          // Event category (required)
 action:@"visit"               // Event action (required)
 label:screenName             // Event label
 value:nil] build]];          // Event value
 }
 
 */
