//
//  ChangeViewController.swift
//  VibesFM
//
//  Created by Admin on 4/17/17.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit

class ChangeViewController: UIViewController {

    @IBOutlet weak var schTemp1: UISwitch!
    @IBOutlet weak var schTemp2: UISwitch!
    @IBOutlet weak var schTemp3: UISwitch!
    @IBOutlet weak var schTemp4: UISwitch!
    @IBOutlet weak var schTemp5: UISwitch!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //schTemp1.enabled = false
        // Do any additional setup after loading the view.
        
        schTemp1.on = false
        schTemp2.on = false
        schTemp3.on = false
        schTemp4.on = false
        schTemp5.on = false
        if SharedData.templateID == 0 {
            schTemp1.on = true
        }
        else if SharedData.templateID == 1 {
            schTemp2.on = true
        }
        else if SharedData.templateID == 2 {
            schTemp3.on = true
        }
        else if SharedData.templateID == 3 {
            schTemp4.on = true
        }
        else if SharedData.templateID == 4 {
            schTemp5.on = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let name = "ChangeDesign-View"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        loadContent()
    }
    
    func loadContent() {
        print(Constants.WebServiceApi.changeDesign)
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.changeDesign, params: nil, completion: { (response, error) -> Void in
            if (response != nil) {
                let strResponse = String(data: response as! NSData, encoding: NSUTF8StringEncoding)
                
                if (strResponse != nil) {
                    var str = strResponse
                    //str = str!.stringByReplacingOccurrencesOfString("(", withString: "")
                    str = str!.stringByReplacingOccurrencesOfString("\n", withString: "")
                    //str = str!.stringByReplacingOccurrencesOfString(")", withString: "")
                    str = str!.stringByReplacingOccurrencesOfString("\n", withString: "")
                    //let json = JSON(data: str!)
                    let data = str!.dataUsingEncoding(NSUTF8StringEncoding)
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                    let posts = json["menus"] as? NSArray
                    
                    if posts != nil {
                        var str1 = ""
                        for i in posts! {
                            var buf = i["name"] as! String
                            buf = "<h4>" + buf + "</h4>"
                            str1 += buf
                            str1 += i["lists"] as! String
                        }
                        
                        SharedData.changeDesignString = str1
                        self.webView.loadHTMLString(SharedData.changeDesignString!, baseURL: nil)
                    }
                    
                    print(json)
                    print(str)
                    //block(success: true, radio: radio_info)
                } else {
                    //block(success: false, radio: nil)
                }
            } else {
                //block(success: false, radio: nil)
            }
        })

    }
    
    @IBAction func changedTemp1(sender: AnyObject) {
        
        schTemp1.on = true
        schTemp2.on = false
        schTemp3.on = false
        schTemp4.on = false
        schTemp5.on = false
        SharedData.templateID = 0
        (SharedData.delegate as! ViewController).imgNav.hidden = false
        (SharedData.delegate as! ViewController).imgNav.hidden = false
        (SharedData.delegate as! ViewController).imgPower.hidden = false
        (SharedData.delegate as! ViewController).imgEffect1.hidden = false
        (SharedData.delegate as! ViewController).imgAddtional.hidden = false
        (SharedData.delegate as! ViewController).imgEffect2.hidden = false
        (SharedData.delegate as! ViewController).imgFooter.hidden = false
        (SharedData.delegate as! ViewController).imgRitaMark.hidden = true
        (SharedData.delegate as! ViewController).m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 1)
        (SharedData.delegate as! ViewController).imgNewNav.hidden = true
        (SharedData.delegate as! ViewController).imgMain.hidden = true
        (SharedData.delegate as! ViewController).btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
        NSUserDefaults.standardUserDefaults().setObject(SharedData.templateID, forKey: "template")
        changePlayStop()
    }
    
    @IBAction func changedTemp2(sender: AnyObject) {
        
        schTemp2.on = true
        schTemp1.on = false
        schTemp3.on = false
        schTemp4.on = false
        schTemp5.on = false
        SharedData.templateID = 1
        (SharedData.delegate as! ViewController).imgNav.hidden = true
        (SharedData.delegate as! ViewController).imgPower.hidden = true
        (SharedData.delegate as! ViewController).imgEffect1.hidden = true
        (SharedData.delegate as! ViewController).imgAddtional.hidden = true
        (SharedData.delegate as! ViewController).imgEffect2.hidden = true
        (SharedData.delegate as! ViewController).imgFooter.hidden = true
        (SharedData.delegate as! ViewController).imgRitaMark.hidden = true
        (SharedData.delegate as! ViewController).m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
        (SharedData.delegate as! ViewController).imgNewNav.hidden = false
        (SharedData.delegate as! ViewController).imgNewNav.image = UIImage(named: "nav_blue.png")
        (SharedData.delegate as! ViewController).imgMain.hidden = false
        (SharedData.delegate as! ViewController).imgMain.image = UIImage(named: "main_blue.png")
        NSUserDefaults.standardUserDefaults().setObject(SharedData.templateID, forKey: "template")
        (SharedData.delegate as! ViewController).btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
        changePlayStop()
    }
    
    @IBAction func changedTemp3(sender: AnyObject) {
        
        schTemp3.on = true
        schTemp2.on = false
        schTemp1.on = false
        schTemp4.on = false
        schTemp5.on = false
        SharedData.templateID = 2
        (SharedData.delegate as! ViewController).imgNav.hidden = true
        (SharedData.delegate as! ViewController).imgPower.hidden = true
        (SharedData.delegate as! ViewController).imgEffect1.hidden = true
        (SharedData.delegate as! ViewController).imgAddtional.hidden = true
        (SharedData.delegate as! ViewController).imgEffect2.hidden = true
        (SharedData.delegate as! ViewController).imgFooter.hidden = true
        (SharedData.delegate as! ViewController).imgRitaMark.hidden = false
        (SharedData.delegate as! ViewController).m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
        (SharedData.delegate as! ViewController).imgNewNav.hidden = false
        (SharedData.delegate as! ViewController).imgNewNav.image = UIImage(named: "nav_rita.png")
        (SharedData.delegate as! ViewController).imgMain.hidden = false
        (SharedData.delegate as! ViewController).imgMain.image = UIImage(named: "main_rita.png")
        (SharedData.delegate as! ViewController).btnFaceBook.setImage(UIImage(named: "fb_pink.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnTwitter.setImage(UIImage(named: "twitter_pink.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnGlobe.setImage(UIImage(named: "web_pink.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnInfo.setImage(UIImage(named: "shop_pink.png"), forState: UIControlState.Normal)
        NSUserDefaults.standardUserDefaults().setObject(SharedData.templateID, forKey: "template")
        changePlayStop()
    }
    
    @IBAction func changedTemp4(sender: AnyObject) {
        
        schTemp4.on = true
        schTemp2.on = false
        schTemp3.on = false
        schTemp1.on = false
        schTemp5.on = false
        SharedData.templateID = 3
        (SharedData.delegate as! ViewController).imgNav.hidden = true
        (SharedData.delegate as! ViewController).imgPower.hidden = true
        (SharedData.delegate as! ViewController).imgEffect1.hidden = true
        (SharedData.delegate as! ViewController).imgAddtional.hidden = true
        (SharedData.delegate as! ViewController).imgEffect2.hidden = true
        (SharedData.delegate as! ViewController).imgFooter.hidden = true
        (SharedData.delegate as! ViewController).imgRitaMark.hidden = true
        (SharedData.delegate as! ViewController).m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
        (SharedData.delegate as! ViewController).imgNewNav.hidden = false
        (SharedData.delegate as! ViewController).imgNewNav.image = UIImage(named: "nav_red.png")
        (SharedData.delegate as! ViewController).imgMain.hidden = false
        (SharedData.delegate as! ViewController).imgMain.image = nil
        (SharedData.delegate as! ViewController).imgMain.backgroundColor = UIColor(hex:"ba0023")
        NSUserDefaults.standardUserDefaults().setObject(SharedData.templateID, forKey: "template")
        (SharedData.delegate as! ViewController).btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
        changePlayStop()
    }
    
    @IBAction func changedTemp5(sender: AnyObject) {
        
        schTemp5.on = true
        schTemp2.on = false
        schTemp3.on = false
        schTemp4.on = false
        schTemp1.on = false
        SharedData.templateID = 4
        (SharedData.delegate as! ViewController).imgNav.hidden = true
        (SharedData.delegate as! ViewController).imgPower.hidden = true
        (SharedData.delegate as! ViewController).imgEffect1.hidden = true
        (SharedData.delegate as! ViewController).imgAddtional.hidden = true
        (SharedData.delegate as! ViewController).imgEffect2.hidden = true
        (SharedData.delegate as! ViewController).imgFooter.hidden = true
        (SharedData.delegate as! ViewController).imgRitaMark.hidden = true
        (SharedData.delegate as! ViewController).m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
        (SharedData.delegate as! ViewController).imgNewNav.hidden = false
        (SharedData.delegate as! ViewController).imgNewNav.image = UIImage(named: "nav_naomi.png")
        (SharedData.delegate as! ViewController).imgMain.hidden = false
        (SharedData.delegate as! ViewController).imgMain.image = nil
        (SharedData.delegate as! ViewController).imgMain.backgroundColor = UIColor(hex:"3a98eb")
        (SharedData.delegate as! ViewController).btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
        (SharedData.delegate as! ViewController).btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
        NSUserDefaults.standardUserDefaults().setObject(SharedData.templateID, forKey: "template")
        changePlayStop()
    }
    
    func changePlayStop() {
        if ((SharedData.delegate as! ViewController).bRadioPlaying) {
            if SharedData.templateID == 2 {
                (SharedData.delegate as! ViewController).m_btnPlayStop.setImage(UIImage(named: "stop_pink.png"), forState: .Normal)
            }
            else {
                (SharedData.delegate as! ViewController).m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
            }
        }
        else {
            
            if SharedData.templateID == 2 {
                (SharedData.delegate as! ViewController).m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                (SharedData.delegate as! ViewController).m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            
        }
    }
    
}
