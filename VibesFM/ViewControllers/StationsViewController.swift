//
//  StationsViewController.swift
//  VibesFM
//
//  Created by Admin on 4/17/17.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit

class StationsViewController: UIViewController {

    @IBOutlet weak var schUltimate: UISwitch!
    @IBOutlet weak var schContemporary: UISwitch!
   // var radioManager: RadioManager = RadioManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = "Stations-View"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        if SharedData.stationState == 0 {
            schUltimate.on = true
            schContemporary.on = false
        }
        else {
            schUltimate.on = false
            schContemporary.on = true
        }
    }
   
    @IBAction func changedUltimate(sender: AnyObject) {
        //
        if schUltimate.on == true{
            schContemporary.on = false
            SharedData.stationState = 0
        }
        else {
            schContemporary.on = true
            SharedData.stationState = 1
        }
        (SharedData.delegate as! ViewController).radioManager.stopCurrentPlayer()
        (SharedData.delegate as! ViewController).loadStream()
        NSUserDefaults.standardUserDefaults().setObject(SharedData.stationState, forKey: "station")
        //(SharedData.delegate as! ViewController).radioManager.playRadio()
    }
    
    
    @IBAction func changedContemporary(sender: AnyObject) {
        //(SharedData.delegate as! ViewController).loadStream()
        if schContemporary.on == true{
            schUltimate.on = false
            SharedData.stationState = 1
        }
        else {
            schUltimate.on = true
            SharedData.stationState = 0
        }
        (SharedData.delegate as! ViewController).radioManager.stopCurrentPlayer()
        (SharedData.delegate as! ViewController).loadStream()
        NSUserDefaults.standardUserDefaults().setObject(SharedData.stationState, forKey: "station")
        //(SharedData.delegate as! ViewController).radioManager.playRadio()
    }
    
}
