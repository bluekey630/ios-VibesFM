//
//  ViewController.swift
//  VibesFM
//
//  Created by Admin on 21/01/2017.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AudioToolbox
import MarqueeLabel
import  UserNotifications
import StoreKit

class ViewController: UIViewController, GADBannerViewDelegate, RadioManagerDelegate, PopUpViewControllerDelegate, SKProductsRequestDelegate,
    SKPaymentTransactionObserver
{
    var bLoadedView: Bool = false
    var bRadioPlaying: Bool = false
    var defaultArtistImage: UIImage? = nil
    
    var bStartTimer: Bool = false
    
   
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    var menuOpened = false
    var menuArray:NSArray?
    var menuItem:NSMutableArray?
    var count = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var childContainerView: UIView!
    private var containerViewController: UIViewController?
    
    
    @IBOutlet weak var m_imgArtist: UIImageView!
    @IBOutlet weak var m_imgNextArtist: UIImageView!
    @IBOutlet weak var m_constraintArtistHeight: NSLayoutConstraint!
    @IBOutlet weak var m_lblNextArtist: UILabel!
    
    @IBOutlet weak var m_nowPlayingBar: UIImageView!
    
    @IBOutlet weak var m_bannerView: GADBannerView!
    
    @IBOutlet weak var m_lblArtist: UILabel!
    @IBOutlet weak var m_bufferingActivity: UIActivityIndicatorView!
    @IBOutlet weak var m_lblTitle: MarqueeLabel!
    
    @IBOutlet weak var m_btnPlayStop: UIButton!
    
    var m_sliderTime: TLTiltSlider? = nil
    @IBOutlet weak var m_lblRemainingTime: UILabel!
    @IBOutlet weak var m_lblRadioInfo: UILabel!
    
    @IBOutlet weak var m_viewSlider: UIView!
    @IBOutlet weak var m_viewCanvas: UIView!
    
    @IBOutlet weak var m_constraintSocialButtonBottom: NSLayoutConstraint!
    
    @IBOutlet weak var imgNav: UIImageView!
    @IBOutlet weak var imgNewNav: UIImageView!
    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var imgPower: UIImageView!
    @IBOutlet weak var imgEffect1: UIImageView!
    @IBOutlet weak var imgAddtional: UIImageView!
    @IBOutlet weak var imgEffect2: UIImageView!
    @IBOutlet weak var imgFooter: UIImageView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var btnFaceBook: UIButton!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnGlobe: UIButton!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var imgRitaMark: UIImageView!
    
    @IBOutlet weak var lblPreContent: UILabel!
    
    @IBOutlet weak var preContainerView: UIView!
    @IBOutlet weak var preContentView: UIView!
    
    @IBOutlet weak var btnProceed: UIButton!
    var stete = 0
    
    var radioManager: RadioManager = RadioManager.init()

    var timer: NSTimer? = nil
    var radioInfoRefreshTimer: NSTimer? = nil
    var curPlayingRadioLength: Int = 0
    var curRadioTitle: String = ""
    var curRadioArtist: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preContainerView.hidden = true
        preContentView.hidden = true
        
        btnProceed.enabled = false
        
        if (SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(objects: "29042017")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        }
        else {
            print("please enable IAPS")
            
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
        TheGlobalPoolManager.currentRadioViewCon = self
        
        
        menuOpened = false
        leadingConstraint.constant = -self.view.frame.width
        loadMenuItem()
        containerView.hidden = true
        SharedData.delegate = self
        self.imgRitaMark.hidden = true
        let defaults = NSUserDefaults.standardUserDefaults()
        if let settings = defaults.objectForKey("template")
        {
            SharedData.templateID = settings as! Int
            changeDesign(SharedData.templateID)
        }        
        
        
        if let station = defaults.objectForKey("station")
        {
            SharedData.stationState = station as! Int
        }
        
        if let settings = NSUserDefaults.standardUserDefaults().objectForKey("alarm")
        {
            let setting = settings as! NSDictionary
            let buf:[String:AnyObject] = ["hour":setting["hour"]!, "min":setting["min"]!, "alarm":false]
            
            let center = UNUserNotificationCenter.currentNotificationCenter()
            center.removeAllPendingNotificationRequests()
            NSUserDefaults.standardUserDefaults().setObject(buf, forKey: "alarm")
            
        }
        
        
        if let pre = defaults.objectForKey("premium") {
            SharedData.isPremiumUser = pre as! Bool
        }
        
        loadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = "Main-View"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //InterfaceManager.makeRadiusControl(self.m_imgNextArtist, cornerRadius: CGRectGetHeight(self.m_imgNextArtist.bounds) / 2.0, withColor: UIColor.clearColor(), borderSize: 0.0)
        InterfaceManager.makeRadiusControl(self.m_viewSlider, cornerRadius: 4.0, withColor: UIColor.clearColor(), borderSize: 0.0)
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        addTimeSlider()
        makeUserInterface()
        initSongHistoryUI()
        loadAdmobBanner()
        loadStream()
        if let setting = NSUserDefaults.standardUserDefaults().objectForKey("settings")
        {
            SharedData.settingsDic = setting as? NSDictionary
            
            if !(SharedData.settingsDic!["auto"] as! Bool) {
                radioManager.stopCurrentPlayer()
                
                self.m_btnPlayStop.setImage(nil, forState: .Normal)
                if SharedData.templateID == 2 {
                    let img = UIImage(named: "play_pink.png")
                    self.m_btnPlayStop.setImage(img, forState: .Normal)
                }
                else {
                    self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
                }
                bRadioPlaying = false
                self.stopTimer()
                
            }
        }
        //loadStream()
    }
    
    func addTimeSlider() {
        self.m_sliderTime = TLTiltSlider.init(frame: self.m_viewSlider.bounds)
        self.m_viewSlider.addSubview(self.m_sliderTime!)
        self.m_sliderTime!.tiltEnabled = false
    }
    
    func makeUserInterface() {
        if (CGRectGetHeight(UIScreen.mainScreen().bounds) == 480) { //for iphone4s
            self.m_constraintArtistHeight.constant = -110.0
            self.view.layoutIfNeeded()
        }
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            self.m_constraintSocialButtonBottom.constant = 30.0
            self.view.layoutIfNeeded()
        }
        
        self.m_viewCanvas.hidden = true
        self.m_bufferingActivity.hidden = true
        
        self.m_lblNextArtist.text = ""
//        self.m_lblTitle.text = ""
//        self.m_lblArtist.text = ""
        self.m_lblRemainingTime.text = ""
        self.m_lblRadioInfo.hidden = true

        m_lblTitle.marqueeType = .MLContinuous
        m_lblTitle.scrollDuration = 20.0
        m_lblTitle.fadeLength = 20
        m_lblTitle.leadingBuffer = 0.0
        m_lblTitle.trailingBuffer = 0.0
        m_lblTitle.textAlignment = .Left
        
        self.m_sliderTime!.value = 0.0//Float(SharedData.valTime)
        self.m_sliderTime!.enabled = false
        self.m_btnPlayStop.setImage(nil, forState: .Normal)
        if SharedData.templateID == 2 {
            self.m_btnPlayStop.setImage(UIImage(named: "stop_pink.png"), forState: .Normal)
        }
        else {
            self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
        }
        
        
        self.m_nowPlayingBar.hidden = true
        self.m_nowPlayingBar.image =
            UIImage(named: "NowPlayzingBars-3")
        self.m_nowPlayingBar.animationImages = AnimationFrames.createFrames()
        self.m_nowPlayingBar.animationDuration = 0.7
        
        self.m_imgArtist.image = UIImage(named: Constants.DefaultIcons.Artist)
        self.m_imgNextArtist.image = UIImage(named: Constants.DefaultIcons.Artist)
        InterfaceManager.addShadowEffectToView(self.m_imgNextArtist, shadowSize: 2.0, yOffset: 0.0, withColor: UIColor.redColor().colorWithAlphaComponent(0.4))
        
        self.m_imgArtist.setImageWithURL(NSURL(string: Constants.WebServiceApi.DefaultArtistURL), placeholderImage: UIImage(named: Constants.DefaultIcons.Artist), options: SDWebImageOptions.RefreshCached, completed: { (image, error, cacheType, url) in
                if (error == nil) {
                    self.defaultArtistImage = image
                } else {
                    self.defaultArtistImage = UIImage(named: Constants.DefaultIcons.Artist)
                }
                self.m_imgArtist.image = self.defaultArtistImage
                self.m_imgNextArtist.image = self.defaultArtistImage
            }, usingActivityIndicatorStyle: .WhiteLarge)
    }
    
    func initSongHistoryUI() {
        for nIdx in 0..<2 {
            let lblArtist = self.view.viewWithTag(40 + 10 * nIdx) as! MarqueeLabel
            let lblTitle = self.view.viewWithTag(41 + 10 * nIdx) as! MarqueeLabel
            let lblDuration = self.view.viewWithTag(42 + 10 * nIdx) as! UILabel
            let lblTime = self.view.viewWithTag(43 + 10 * nIdx) as! UILabel
            
            lblArtist.marqueeType = .MLContinuous
            lblArtist.scrollDuration = 24.0
            lblArtist.fadeLength = 0
            lblArtist.leadingBuffer = 0.0
            lblArtist.trailingBuffer = 0.0
            lblArtist.textAlignment = .Left

            lblTitle.marqueeType = .MLContinuous
            lblTitle.scrollDuration = 24.0
            lblTitle.fadeLength = 0
            lblTitle.leadingBuffer = 0.0
            lblTitle.trailingBuffer = 0.0
            lblTitle.textAlignment = .Left

            lblArtist.text = ""
            lblTitle.text = ""
            lblDuration.text = ""
            lblTime.text = ""
        }
    }
    
    func loadAdmobBanner() {
        m_bannerView.adUnitID = Constants.AdMob.Banner
        m_bannerView.rootViewController = self
        m_bannerView.delegate = self
        m_bannerView.loadRequest(GADRequest())
    }
    
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        print("admob banner is loaded")
        /*
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.m_constraintBannerBottom.constant = 0.0
            
            self.view.layoutIfNeeded()
        })
        */
    }

    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print(error)
    }
    
    func loadStream() {
        radioManager.delegate = self
        //SharedData.stationState = 0
        if SharedData.stationState == 0 {
            radioManager.createStreamer(Constants.RadioStationURL)
        }
        else {
            radioManager.createStreamer(Constants.RadioStationURL1)
        }
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        
        self.resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if (event?.type == .RemoteControl) {
            switch event!.subtype {
            case .RemoteControlPause:
                if (radioManager.radio != nil) {
                    if (radioManager.radio.isPlaying()) {
                        radioManager.radio.pause()
                    }
                }
            case .RemoteControlPlay:
                if (radioManager.radio != nil) {
                    if (radioManager.radio.isPaused()) {
                        radioManager.radio.play()
                    }
                }
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func togglePlayStop(sender: AnyObject) {
        radioManager.playRadio()
        
        if (bRadioPlaying) {
            radioManager.stopCurrentPlayer()//stop
            bRadioPlaying = false
            m_lblRemainingTime.text = "00:00"
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                let img = UIImage(named: "play_pink.png")
                self.m_btnPlayStop.setImage(img, forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            
            self.stopTimer()
        } else { //play
            loadStream()
            bRadioPlaying = true
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "stop_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
        }
    }

    @IBAction func actionGame(sender: AnyObject) {
    }
    
    @IBAction func actionShareFacebook(sender: AnyObject) {
        self.showPopUpViewCon(Constants.SocialLink.Facebook)
    }
    
    @IBAction func actionShareTwitter(sender: AnyObject) {
        self.showPopUpViewCon(Constants.SocialLink.Twitter)
    }
    
    @IBAction func actionGlobe(sender: AnyObject) {
        self.showPopUpViewCon(Constants.SocialLink.Website)
    }
    
    @IBAction func actionInfo(sender: AnyObject) {
        self.showPopUpViewCon(Constants.SocialLink.Info)
    }
    
    func showPopUpViewCon(webSiteLink: String) {
        self.m_viewCanvas.hidden = false
        
        let viewCon = self.storyboard?.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        viewCon.m_strWebSiteLink = webSiteLink
        viewCon.delegate = self
        
        self.addChildViewController(viewCon)
        self.m_viewCanvas.addSubview(viewCon.view)
        viewCon.didMoveToParentViewController(self)
        viewCon.view.frame = self.m_viewCanvas.bounds
    }
    
    func actionDismissViewCon(viewCon: PopUpViewController) {
        viewCon.willMoveToParentViewController(nil)
        viewCon.view.removeFromSuperview()
        viewCon.removeFromParentViewController()
        
        self.m_viewCanvas.hidden = true
    }
    
    func startTimer() {
        self.bStartTimer = true
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.timerProc), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if (self.bStartTimer) {
            self.bStartTimer = false
            
            if (self.timer != nil) {
                self.timer?.invalidate()
            }
        }
        
        self.m_sliderTime!.value = 0.0
        self.m_sliderTime!.enabled = false
        self.m_sliderTime!.maximumValue = Float(SharedData.maxTime)

        self.timer = nil
    }
    
    func timerProc() {
        if (!self.bStartTimer) {
            return
        }
        print("SharedData.valTime ================>\(SharedData.valTime)")
        if SharedData.valTime == 0 {
            loadCurrentArtistImage()
        }
        SharedData.valTime -= 1
        if (SharedData.valTime < 0) {
            SharedData.valTime = 0
            self.m_lblRemainingTime.text = "Still Playing..."
            return
        }
        print(SharedData.valTime)
        print("MaxVal+++++++++++++>\(SharedData.maxTime)")
        print("SliderVal+++++++++>\(Float(SharedData.maxTime - SharedData.valTime))")
        self.m_lblRemainingTime.hidden = false
        self.m_lblRemainingTime.text = TheGlobalPoolManager.makeSecondsTime(SharedData.maxTime - SharedData.valTime)//self.curPlayingRadioLength
        self.m_sliderTime!.maximumValue = Float(SharedData.maxTime)
        self.m_sliderTime!.value = Float(SharedData.maxTime - SharedData.valTime)//self.m_sliderTime!.maximumValue - Float(self.curPlayingRadioLength)
        
//        if SharedData.contactString == nil {
//            loadContact()
//        }
//        
//        if SharedData.faqString == nil {
//            loadFAQ()
//        }
//        
//        if SharedData.imprintString == nil {
//            loadImprint()
//        }
//        
//        if SharedData.termsPolicyString == nil {
//            loadTermsPolicy()
//        }
//        
//        if SharedData.alarmString == nil {
//            loadAlarmString()
//        }
//        
//        if SharedData.changeDesignString == nil {
//            loadChangeContent()
//        }
        
    }
    
    func radioInfoWithTitle(strTitle: String!, withArtist strArtist: String!) {
        print("radio info with title**************")
        if (curRadioTitle != strTitle || curRadioArtist != strArtist) {
            //new song
            print("**********new song**************")
            self.loadSongHistory()
        }

        if (self.bRadioPlaying) {
            prepareRadioPlaying(strTitle, withArtist: strArtist)
            
            //self.m_lblTitle.text = curRadioTitle
            //self.m_lblArtist.text = curRadioArtist
            
            print("song----------delegate-----title: \(curRadioTitle), artist: \(curRadioArtist) ----")
        }
    }
    
    func prepareRadioPlaying(strTitle: String!, withArtist strArtist: String!) {
        self.stopTimer()

        curPlayingRadioLength = getRadioDurationFromTitle(strTitle).0 - 2
        let radioTitle = getRadioDurationFromTitle(strTitle).1
        if (curPlayingRadioLength < 0) {
            curPlayingRadioLength = 0
        }
        
        //self.m_lblRemainingTime.text = TheGlobalPoolManager.makeSecondsTime(curPlayingRadioLength)
        self.m_sliderTime!.maximumValue = Float(SharedData.maxTime)
        if (SharedData.valTime == 0) {
            self.m_lblRemainingTime.hidden = true
        } else {
            self.m_lblRemainingTime.hidden = false
        }
        
        self.startTimer()
        if strArtist == nil {
            curRadioArtist = ""
        }
        else {
            curRadioTitle = radioTitle
        }
        
        removeWhiteSpaceFromString()
        
        loadLockScreenInfo()
        loadCurrentArtistImage()
    }
    
    func removeWhiteSpaceFromString() {
        curRadioArtist = curRadioArtist.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        curRadioTitle = curRadioTitle.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func loadLockScreenInfo() {
        let nowPlayingInfo = [MPMediaItemPropertyArtist: curRadioArtist,
                              MPMediaItemPropertyTitle: curRadioTitle,
//                              MPMediaItemPropertyTitle: "VIBES FM Hamburg"
                              MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: UIImage(named: "sleep_image.png")!)]
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    
    func loadSongHistory() {
        TheAPIManagerManager.getSongHistory { (success, songs) in
            if (success) {
                self.showSongHistoryInfo(songs)
            }
        }
    }
    
    func showSongHistoryInfo(songs: [SongHistory]) {
        for nIdx in 0..<2 {
            let lblArtist = self.view.viewWithTag(40 + 10 * nIdx) as! MarqueeLabel
            let lblTitle = self.view.viewWithTag(41 + 10 * nIdx) as! MarqueeLabel
            let lblDuration = self.view.viewWithTag(42 + 10 * nIdx) as! UILabel
            let lblTime = self.view.viewWithTag(43 + 10 * nIdx) as! UILabel
            
            if (nIdx == 0 && songs.count >= 1) {
                lblArtist.text = songs[nIdx].artist
                lblTitle.text = songs[nIdx].title
                lblDuration.text = songs[nIdx].duration
                lblTime.text = songs[nIdx].time
            } else if (nIdx == 1 && songs.count >= 2) {
                lblArtist.text = songs[nIdx].artist
                lblTitle.text = songs[nIdx].title
                lblDuration.text = songs[nIdx].duration
                lblTime.text = songs[nIdx].time
            } else {
                lblArtist.text = ""
                lblTitle.text = ""
                lblDuration.text = ""
                lblTime.text = ""
            }
        }
    }

    func loadCurrentArtistImage() {
        TheAPIManagerManager.getRadioArtist { (success, artistImageLink, artistName, songTitle, remainingTime, comingSoonImagelink, comingSoonName) in
            if (success) {
                self.m_lblTitle.text = songTitle
                self.m_lblArtist.text = artistName
                //self.m_lblNextArtist.text = comingSoon
                if artistName.length > 20 {
                    print(artistName)
                }
                self.curRadioArtist = artistName
                self.curRadioTitle = songTitle
                self.removeWhiteSpaceFromString()
                self.m_lblNextArtist.text = comingSoonName
                self.loadLockScreenInfo()
                
                var BaseArtistURL = ""
                
                if SharedData.stationState == 0 {
                    BaseArtistURL = Constants.WebServiceApi.BaseArtistURL
                }
                else {
                    BaseArtistURL = Constants.WebServiceApi.BaseArtistURL1
                }
                let imageurl = BaseArtistURL+artistImageLink
                self.m_imgArtist.setImageWithURL(NSURL(string: imageurl), placeholderImage: self.defaultArtistImage, options: SDWebImageOptions.RefreshCached, usingActivityIndicatorStyle: .WhiteLarge)
                
//                var nextArtistImageName = comingSoonImagelink.stringByReplacingOccurrencesOfString("-", withString: "")
//                nextArtistImageName = nextArtistImageName.stringByReplacingOccurrencesOfString(" ", withString: "")
                //let nextArtistImageNameURL = "\(Constants.WebServiceApi.BaseArtistURL)\(nextArtistImageName.lowercaseString).jpg"
                self.m_imgNextArtist.setImageWithURL(NSURL(string: BaseArtistURL+comingSoonImagelink), placeholderImage: self.defaultArtistImage, usingActivityIndicatorStyle: .WhiteLarge)
                
                print("curPlayingRadioLength=====\(self.curPlayingRadioLength)\nremainingTime======\(remainingTime)")
                if (self.curPlayingRadioLength == 0 && remainingTime > 2) {
                    self.curPlayingRadioLength = remainingTime - 2
                    self.m_lblRemainingTime.text = TheGlobalPoolManager.makeSecondsTime(self.curPlayingRadioLength)
                    self.m_sliderTime!.maximumValue = Float(SharedData.maxTime)
                    self.m_lblRemainingTime.hidden = false
                }
            } else {
                self.m_imgArtist.image = self.defaultArtistImage
            }
        }
        
        /*
        if (curRadioArtist.length == 0) {
            return
        }
        
        var artistImageName = curRadioArtist.stringByReplacingOccurrencesOfString("-", withString: "")
        artistImageName = artistImageName.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let artistImageNameURL = "\(Constants.WebServiceApi.BaseArtistURL)\(artistImageName.lowercaseString).jpg"
        self.m_imgArtist.setImageWithURL(NSURL(string: artistImageNameURL), placeholderImage: self.defaultArtistImage, usingActivityIndicatorStyle: .WhiteLarge)
        */
    }
    
    func getRadioDurationFromTitle(strTitle: String) -> (Int, String) {
        if (strTitle.length < 7) {
            return (0, strTitle)
        }
        
        let strDuration = strTitle.substring(strTitle.length - 7)
        let durationItems = strDuration.componentsSeparatedByString(":")
        if (durationItems.count < 2) {
            self.stopTimer()
            
//            self.m_lblRemainingTime.text = TheGlobalPoolManager.makeSecondsTime(0)
//            
//            self.m_sliderTime!.value = 0.0//Float(SharedData.valTime)
//            self.m_sliderTime!.enabled = false
//            self.m_sliderTime!.maximumValue = Float(SharedData.maxTime)
            
            return (0, strTitle)
        }
        
        let radioArtist = strTitle.substringToIndex(strTitle.endIndex.advancedBy(-7))
        
        let strDurationMin = durationItems[0].stringByReplacingOccurrencesOfString("(", withString: "")
        let strDurationSec = durationItems[1].stringByReplacingOccurrencesOfString(")", withString: "")
        
        let radioLength = Int(strDurationMin)! * 60 + Int(strDurationSec)!
        
        return (radioLength, radioArtist)
    }
    
    func beginInterruption() {
        if (radioManager.radio == nil) {
            return
        }
        
        radioManager.radio.pause()
    }
    
    func endInterruption() {
        if (radioManager.radio == nil) {
            return
        }
        
        if (radioManager.radio.isPaused()) {
            radioManager.radio.play()
        }
    }
    
    func radioMetadataReady(strMetaData: String!) {
        //self.m_lblTitle.text = "\(strMetaData)"
    }
    
    func radioStateChanged(radioState: RadioState) {
        if (radioState.rawValue == kRadioStateConnecting.rawValue) {
            self.m_lblTitle.text = "Status: Connecting"
            self.m_lblArtist.text = ""
            self.bRadioPlaying = false
            self.m_btnPlayStop.enabled = false
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            self.m_nowPlayingBar.hidden = true
            self.m_lblRadioInfo.hidden = true
            self.m_lblRemainingTime.text = ""
        } else if (radioState.rawValue == kRadioStateBuffering.rawValue) {
            self.m_lblTitle.text = "Status: Buffering"
            self.m_lblArtist.text = ""
            self.bRadioPlaying = false
            self.m_btnPlayStop.enabled = false
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            self.m_nowPlayingBar.hidden = true
            self.m_lblRadioInfo.hidden = true
            self.m_lblRemainingTime.text = ""
            self.stopTimer()
            self.m_bufferingActivity.startAnimating()
            self.m_bufferingActivity.hidden = false
        } else if (radioState.rawValue == kRadioStatePlaying.rawValue) {
            if (self.m_lblTitle.text == "Status: Buffering") {
                self.m_lblTitle.text = "Status: Playing"
            }
            
            self.bRadioPlaying = true
            self.m_btnPlayStop.enabled = true
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "stop_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
            self.m_nowPlayingBar.hidden = false
            self.m_nowPlayingBar.startAnimating()
            self.m_lblRadioInfo.hidden = false
            self.m_lblRemainingTime.text = "00:00"

            prepareRadioPlaying(self.radioManager.metadataTitle, withArtist: self.radioManager.metadataArtist)
            
            self.m_lblTitle.text = curRadioTitle
            self.m_lblArtist.text = curRadioArtist
            self.m_bufferingActivity.stopAnimating()
            self.m_bufferingActivity.hidden = true
        } else if (radioState.rawValue == kRadioStateStopped.rawValue) {
            self.m_imgArtist.image = self.defaultArtistImage
            self.m_imgNextArtist.image = self.defaultArtistImage
            self.m_lblArtist.text = ""
            self.m_lblTitle.text = "Status: Stopped"
            self.bRadioPlaying = false
            self.m_btnPlayStop.enabled = true
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            self.m_nowPlayingBar.hidden = true
            self.m_lblRadioInfo.hidden = true
            self.m_lblRemainingTime.text = ""
            self.stopTimer()
            self.m_bufferingActivity.stopAnimating()
            self.m_bufferingActivity.hidden = true
        } else if (radioState.rawValue == kRadioStateError.rawValue) {
            self.m_imgArtist.image = self.defaultArtistImage
            self.m_imgNextArtist.image = self.defaultArtistImage
            self.m_lblArtist.text = ""
            self.m_lblTitle.text = "Status: Error"
            self.bRadioPlaying = false
            self.m_btnPlayStop.enabled = true
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            self.m_nowPlayingBar.hidden = true
            self.m_lblRadioInfo.hidden = true
            self.m_lblRemainingTime.text = ""
            self.stopTimer()
            self.m_bufferingActivity.stopAnimating()
            self.m_bufferingActivity.hidden = true
            
            self.radioManager.playRadio()
        } else {
            self.m_btnPlayStop.enabled = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    func refreshPlaying(strState: String!) {
        if (strState == "Playing") {
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "stop_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
        } else if (strState == "Paused") {
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
        } else {
            self.m_btnPlayStop.setImage(nil, forState: .Normal)
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            //self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            //self.m_lblTitle.text = ""
        }
    }
    
    func loadMenuItem() {
        print(Constants.WebServiceApi.getMenuItem)
//        WebServiceAPI.sendGetRequest(Constants.WebServiceApi.getMenuItem, params: nil, completion: { (response, error) -> Void in
//            if (response != nil) {
//                let dataArry = response as? NSDictionary
//                print(dataArry)
//                let strResponse = String(data: response as! NSData, encoding: NSUTF8StringEncoding)
//                    
//                if (strResponse != nil) {
//                    
//                    let items = strResponse!.componentsSeparatedByString("|")
//                    print(items)
//                        
////                    let radio_id = items[0]
////                    let radio_remaining_time = Int(items[1])!
////                    let radio_title = items[2]
////                    let radio_artist = items[3]
////                    let radio_artist_logo = items[4]
//                    
//                    //let radio_info = Radio(id: radio_id, remaing_time: radio_remaining_time, title: radio_title, artist_name: radio_artist, artist_logo: radio_artist_logo)
//                        
//                    //block(success: true, radio: radio_info)
//                } else {
//                    //block(success: false, radio: nil)
//                }
//            } else {
//                //block(success: false, radio: nil)
//            }
//        })
        
        self.menuArray = SharedData.menuArray
        self.calc()
        self.tableView.reloadSectionIndexTitles()
        self.tableView.reloadData()
    }

    func calc() {
        
        if self.menuArray == nil {
            return
        }
        self.menuItem = NSMutableArray()
        var k = 0
        for i in self.menuArray! {
            print(i["name"])
           self.menuItem!.addObject(i["name"] as! String)
            k += 1
            let buf = i["lists"] as! NSArray
            for j in buf {
                
                if (SharedData.isPremiumUser == false && k > 7 && k < 12) {
                    if k == 8 {
                        self.menuItem!.addObject("")
                    }
                    
                    k += 1
                    continue
                }
                
                if j.classForCoder.description() == "NSArray" {
                    let ary = j as! NSArray
                    self.menuItem!.addObject(ary[0])
                    //print(self.menuItem![k])
                }
                else {
                    self.menuItem!.addObject(j)
                    //print(self.menuItem![k])
                }
                
                
                k += 1
            }
        }
        
        print(self.menuItem!.count)
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        view.endEditing(true)
        loadMenuItem()
        containerView.hidden = true
        if menuOpened == false {
            leadingConstraint.constant = 0
            menuOpened = true
        }
        else {
            leadingConstraint.constant = -self.view.frame.width
            menuOpened = false
        }
        self.tableView.reloadSectionIndexTitles()
        self.tableView.reloadData()
    }
    
    @IBAction func tappedBack(sender: AnyObject) {
        leadingConstraint.constant = -self.view.frame.width
        menuOpened = false
        containerView.hidden = true
        view.endEditing(true)
        
    }
    
    func changeDesign(state: Int){
        if (bRadioPlaying) {
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "stop_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_stop.png"), forState: .Normal)
            }
        }
        else {
            
            if SharedData.templateID == 2 {
                self.m_btnPlayStop.setImage(UIImage(named: "play_pink.png"), forState: .Normal)
            }
            else {
                self.m_btnPlayStop.setImage(UIImage(named: "icon_play.png"), forState: .Normal)
            }
            
        }
        
        switch state {
        case 0:
            self.imgNav.hidden = false
            self.imgNav.hidden = false
            self.imgPower.hidden = false
            self.imgEffect1.hidden = false
            self.imgAddtional.hidden = false
            self.imgEffect2.hidden = false
            self.imgFooter.hidden = false
            self.imgRitaMark.hidden = true
            self.m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 1)
            self.imgNewNav.hidden = true
            self.imgMain.hidden = true
            self.btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
            self.btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
            self.btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
            self.btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
            break
            
        case 1:
            self.imgNav.hidden = true
            self.imgPower.hidden = true
            self.imgEffect1.hidden = true
            self.imgAddtional.hidden = true
            self.imgEffect2.hidden = true
            self.imgFooter.hidden = true
            self.imgRitaMark.hidden = true
            self.m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
            self.imgNewNav.hidden = false
            self.imgNewNav.image = UIImage(named: "nav_blue.png")
            self.imgMain.hidden = false
            self.imgMain.image = UIImage(named: "main_blue.png")
            self.btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
            self.btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
            self.btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
            self.btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
            break
            
        case 2:
            self.imgNav.hidden = true
            self.imgPower.hidden = true
            self.imgEffect1.hidden = true
            self.imgAddtional.hidden = true
            self.imgEffect2.hidden = true
            self.imgFooter.hidden = true
            self.imgRitaMark.hidden = false
            self.m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
            self.imgNewNav.hidden = false
            self.imgNewNav.image = UIImage(named: "nav_rita.png")
            self.imgMain.hidden = false
            self.imgMain.image = UIImage(named: "main_rita.png")
            self.btnFaceBook.setImage(UIImage(named: "fb_pink.png"), forState: UIControlState.Normal)
            self.btnTwitter.setImage(UIImage(named: "twitter_pink.png"), forState: UIControlState.Normal)
            self.btnGlobe.setImage(UIImage(named: "web_pink.png"), forState: UIControlState.Normal)
            self.btnInfo.setImage(UIImage(named: "shop_pink.png"), forState: UIControlState.Normal)
            break
            
        case 3:
            self.imgNav.hidden = true
            self.imgPower.hidden = true
            self.imgEffect1.hidden = true
            self.imgAddtional.hidden = true
            self.imgEffect2.hidden = true
            self.imgFooter.hidden = true
            self.imgRitaMark.hidden = true
            self.m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
            self.imgNewNav.hidden = false
            self.imgNewNav.image = UIImage(named: "nav_red.png")
            self.imgMain.hidden = false
            self.imgMain.image = nil
            self.imgMain.backgroundColor = UIColor(hex:"ba0023")
            self.btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
            self.btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
            self.btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
            self.btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
            break
            
        case 4:
            self.imgNav.hidden = true
            self.imgPower.hidden = true
            self.imgEffect1.hidden = true
            self.imgAddtional.hidden = true
            self.imgEffect2.hidden = true
            self.imgFooter.hidden = true
            self.imgRitaMark.hidden = true
            self.m_viewSlider.backgroundColor = UIColor(hex: "000000", alpha: 0)
            self.imgNewNav.hidden = false
            self.imgNewNav.image = UIImage(named: "nav_naomi.png")
            self.imgMain.hidden = false
            self.imgMain.image = nil
            self.imgMain.backgroundColor = UIColor(hex:"3a98eb")
            self.btnFaceBook.setImage(UIImage(named: "icon_facebook.png"), forState: UIControlState.Normal)
            self.btnTwitter.setImage(UIImage(named: "icon_twitter.png"), forState: UIControlState.Normal)
            self.btnGlobe.setImage(UIImage(named: "icon_globe.png"), forState: UIControlState.Normal)
            self.btnInfo.setImage(UIImage(named: "icon_shop.png"), forState: UIControlState.Normal)
            break
        default: break
        }
    }
    
    var list = [SKProduct]()
    var p = SKProduct()
    
    @IBAction func tappedProceed(sender: AnyObject) {
        for product in list {
            let prodID = product.productIdentifier
            if (prodID == "29042017") {
                p = product
                buyProduct()
            }
        }
    }
    
    func buyProduct() {
        print("buy" + p.productIdentifier)
        let pay = SKPayment(product: p)
        //SKPaymentQueue.defaultQueue().addPayment(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    func restorePurchase() {
        //SKPaymentQueue.defaultQueue().addPayment(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        
    }
    
    func proceed() {
        preContainerView.hidden = true
        preContentView.hidden = true
        
        SharedData.isPremiumUser = true
        NSUserDefaults.standardUserDefaults().setObject(SharedData.isPremiumUser, forKey: "premium")
        
        calc()
        tableView.reloadData()
    }
    
    @IBAction func tappedCancel(sender: AnyObject) {
        preContainerView.hidden = true
        preContentView.hidden = true
    }
    
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product)
            
        }
        
        btnProceed.enabled = true
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error)
            
            switch trans.transactionState {
            case .Purchased:
                proceed()
                queue.finishTransaction(trans)
                break
            case .Failed:
                print("buy error")
                queue.finishTransaction(trans)
                break
            default:
                print("Default")
                break
            }
        }
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
        
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "29042017":
                print("VibesFM")
            default:
                print("IAP not found")
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.menuItem != nil {
            
            return self.menuItem!.count
        }
        else{
            return 0
        }
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UIMenuTableViewCell", forIndexPath: indexPath) as! UIMenuTableViewCell
        if self.menuItem != nil {
            var flag = false
            for i in self.menuArray! {
                if menuItem![indexPath.row] as! String == i["name"] as! String{
                    flag = true
                    break
                }
            }
            
            if flag == true {
                
                cell.imgConstraint.constant = 10
                cell.nameConstraint.constant = 10
                cell.menuName.text = menuItem![indexPath.row] as? String
                cell.menuName.textColor = UIColor(netHex: 0xe2e183)
                cell.menuName.font = cell.menuName.font.fontWithSize(18)
                cell.menuIcon.image = UIImage(named:"ic_menubig.png")!
                if (indexPath.row == 7  && SharedData.isPremiumUser == false){
                    cell.menuLine.hidden = true
                }
                else {
                    cell.menuLine.hidden = false
                }
            }
            else {
                
                if (indexPath.row == 8 && SharedData.isPremiumUser == false) {
                    cell.imgConstraint.constant = 80
                    cell.nameConstraint.constant = 0
                    cell.menuName.text = menuItem![indexPath.row] as? String
                    cell.menuName.textColor = UIColor(netHex: 0xeeeeee)
                    cell.menuName.font = cell.menuName.font.fontWithSize(16)
                    cell.menuIcon.image = UIImage(named:"icon_info.png")!
                }
                else {
                    cell.imgConstraint.constant = 25
                    cell.nameConstraint.constant = 25
                    cell.menuName.text = menuItem![indexPath.row] as? String
                    cell.menuName.textColor = UIColor(netHex: 0xeeeeee)
                    cell.menuName.font = cell.menuName.font.fontWithSize(16)
                    cell.menuIcon.image = UIImage(named:"ic_menusmall.png")!
                }
                
            }
            
            
        }
        
//        if (indexPath.row > 7 && indexPath.row < 12) {
//            cell.
//        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if self.menuItem != nil {
            var flag = false
            for i in self.menuArray! {
                if menuItem![indexPath.row] as! String == i["name"] as! String{
                    flag = true
                    break
                }
            }
            
            if flag == true {
                
            }
            else {
                
                if (indexPath.row == 1) {
                    loadViewController("StationsViewController")
                    // stations//
                    ////  Check the station template
                    //loadWebView(SharedData.contactString!)
                }
                else if indexPath.row == 2 {
                    // trending
                    if let url = NSURL(string: "https://www.mobile.rohhat.com/radio/vibesfm/json/trending_ads/adcontent.html") {
                        loadWebView(nil, url: url, mode: false)
                        //UIApplication.sharedApplication().openURL(url)
                        let name = "Trending-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                    }
                    //return
                }
                else if indexPath.row == 3 {
                    
                    //service
                    if let url = NSURL(string: "https://mobile.rohhat.com/radio/chat/index.php") {
                        loadWebView(nil, url: url, mode: false)
                        //UIApplication.sharedApplication().openURL(url)
                        let name = "Chatting-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                    }
                    //return
                }
                else if indexPath.row == 4 {
                    //recommended
                    if let url = NSURL(string: "https://www.mobile.rohhat.com/radio/vibesfm/json/recommended/index.html") {
                        //UIApplication.sharedApplication().openURL(url)
                        loadWebView(nil, url: url, mode: false)
                        let name = "Recommended-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                    }
                    //return
                }
                else if indexPath.row == 5 {
                    //FAQ
                    let name = "Faq-View"
                    guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                    tracker.set(kGAIScreenName, value: name)
                    guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                    tracker.send(builder.build() as [NSObject : AnyObject])
                    
                    if SharedData.faqString != nil {
                        loadWebView(SharedData.faqString!,url: nil, mode: true)
                    }
                    else {
                        loadWebView("",url: nil, mode: true)
                    }
                    
                }
                else if indexPath.row == 6 {
                    //Setings
                    // Check Android version //
                    loadViewController("SettingsViewController")
                    
                }
                else if indexPath.row == 8 {
                    //change design
                    // Check Android version and
                    //https://www.mobile.rohhat.com/radio/vibesfm/json/designs.json
                    if SharedData.isPremiumUser {
                        loadViewController("ChangeViewController")
                    }
                    else
                    {
                        preContainerView.hidden = false
                        preContentView.hidden = false
//                        SharedData.isPremiumUser = true
//                        calc()
//                        tableView.reloadData()
                        return
                    }
                    //loadViewController("ChangeViewController")
                }
                else if indexPath.row == 9 {
                    //set Alarms
                    // Check Android version and
                    
                    //https://www.mobile.rohhat.com/radio/vibesfm/json/alarm_content.json
                    if SharedData.isPremiumUser {
                        loadViewController("AlarmViewController")
                    }
                    else {
                        
                        
                    }
                    
                }
                else if indexPath.row == 10 {
                    //Song request
                    // Check Android Version
                    if SharedData.isPremiumUser {
                        SharedData.state = 0
                        loadViewController("RequestViewController")
                    }
                    else {
                        let name = "Contact-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                        if SharedData.contactString != nil {
                            loadWebView(SharedData.contactString!, url: nil, mode: true)
                        }
                        else {
                            loadWebView("",url: nil, mode: true)
                        }
                    }
                    
                }
                else if indexPath.row == 11 {
                    //Song request
                    // Check Android Version
                    if SharedData.isPremiumUser {
                        SharedData.state = 1
                        loadViewController("RequestViewController")
                    }
                    else {
                        let name = "Imprint-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                        if SharedData.imprintString != nil{
                            loadWebView(SharedData.imprintString!,url: nil, mode: true)
                        }
                        else {
                            loadWebView("",url: nil, mode: true)
                        }
                    }
                    
                }
                else if indexPath.row == 12 {
                    if SharedData.isPremiumUser {
                        return
                    }
                    else {
                        let name = "Terms and Policy-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                        if SharedData.termsPolicyString != nil {
                            loadWebView(SharedData.termsPolicyString!,url: nil, mode: true)
                        }
                        else {
                            loadWebView("",url: nil, mode: true)
                        }
                    }
                    
                }
                else if indexPath.row == 13 {
                    //Contact
                    if SharedData.isPremiumUser {
                        let name = "Contact-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                        if SharedData.contactString != nil {
                            loadWebView(SharedData.contactString!, url: nil, mode: true)
                        }
                        else {
                            loadWebView("",url: nil, mode: true)
                        }
                    }
                    else {
                        
                        return
                    }
                    
                }
                else if indexPath.row == 14 {
                    //Imprint
                    if SharedData.isPremiumUser {
                        let name = "Imprint-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                        if SharedData.imprintString != nil{
                            loadWebView(SharedData.imprintString!,url: nil, mode: true)
                        }
                        else {
                            loadWebView("",url: nil, mode: true)
                        }
                    }
                    else {
                        proceed()
                        return
                    }
                }
                else if indexPath.row == 15 {
                    //Terms & Policy
                    if SharedData.isPremiumUser {
                        let name = "Terms and Policy-View"
                        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
                        tracker.set(kGAIScreenName, value: name)
                        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                        tracker.send(builder.build() as [NSObject : AnyObject])
                        if SharedData.termsPolicyString != nil {
                            loadWebView(SharedData.termsPolicyString!,url: nil, mode: true)
                        }
                        else {
                            loadWebView("",url: nil, mode: true)
                        }
                    }
                    else {
                        return
                    }

                }
                else {
                    return
                    //Version 1.2
                }
                
                leadingConstraint.constant = -self.view.frame.width
                menuOpened = false
                containerView.hidden = false
                lblTitle.text = menuItem![indexPath.row] as? String

            }
            
        }
        
    }
    
    func loadWebView(string:String?, url:NSURL?, mode: Bool) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let currentVC = storyboard.instantiateViewControllerWithIdentifier("WebViewController")
//        embedViewController(currentVC)
        
        childContainerView.addSubview(currentVC.view)
        
        self.addChildViewController(currentVC)
        //        viewController.didMove(toParentViewController: self)
        self.containerViewController = currentVC
        
        currentVC.view.frame = self.childContainerView.bounds
        currentVC.view.layoutIfNeeded()
        if mode {
            (currentVC as! WebViewController).containerWebView.loadHTMLString(string!, baseURL: nil)
        }
        else {
        
            (currentVC as! WebViewController).containerWebView.loadRequest(NSURLRequest(URL: url!))
        }
        
    }
    
    func loadViewController(id:String)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let currentVC = storyboard.instantiateViewControllerWithIdentifier(id)
        //        embedViewController(currentVC)
        childContainerView.addSubview(currentVC.view)
        self.addChildViewController(currentVC)
        //viewController.didMove(toParentViewController: self)
        self.containerViewController = currentVC
        
        currentVC.view.frame = self.childContainerView.bounds
        currentVC.view.layoutIfNeeded()
    }
    
    func loadData() {
        loadMenu()
        loadContact()
        loadFAQ()
        loadImprint()
        loadTermsPolicy()
        loadAlarmString()
        loadChangeContent()
        loadPremiumNotice()
    }
    
    func loadMenu() {
        let url = NSURL(string: Constants.WebServiceApi.getMenuItem)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {(data, response, error) in
            guard let data = data where error == nil else { return }
            
            do {
                let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)// as! //[String:Any]
                let posts = json["menus"] as? NSArray
                SharedData.menuArray = posts
                
                
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
    func loadPremiumNotice() {
//        let url = NSURL(string: Constants.WebServiceApi.premiumNotice)
//        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {(data, response, error) in
//            guard let data = data where error == nil else { return }
//            
//            do {
//                let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)// as! //[String:Any]
//                let posts = json["content"] as? NSArray
//                let dic = posts?.firstObject as! NSDictionary
//                
//                SharedData.premiumshortnotice = dic["text"] as! String
//                print(SharedData.premiumshortnotice)
//                
//            } catch let error as NSError {
//                print(error)
//            }
//        }).resume()
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.premiumNotice, params: nil, completion: { (response, error) -> Void in
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
                    
                    let posts = json["content"] as? NSArray
                    let dic = posts?.firstObject as! NSDictionary
                    
                    SharedData.premiumshortnotice = dic["text"] as? String
                    print(SharedData.premiumshortnotice)
                    self.lblPreContent.text = SharedData.premiumshortnotice
                    
                } else {
                    //block(success: false, radio: nil)
                }
            } else {
                //block(success: false, radio: nil)
            }
        })


    }
    
    func loadContact() {
        print(Constants.WebServiceApi.getContact)
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.getContact, params: nil, completion: { (response, error) -> Void in
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
                        
                        SharedData.contactString = str1
                        print(str1)
                    }
                    
                } else {
                    //block(success: false, radio: nil)
                }
            } else {
                //block(success: false, radio: nil)
            }
        })
    }
    
    func loadFAQ() {
        print(Constants.WebServiceApi.getFAQ)
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.getFAQ, params: nil, completion: { (response, error) -> Void in
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
                        SharedData.faqString = str1
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
    
    func loadImprint() {
        print(Constants.WebServiceApi.getImprint)
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.getImprint, params: nil, completion: { (response, error) -> Void in
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
                        
                        SharedData.imprintString = str1
                        print(str1)
                    }
                    
  
                } else {
                    //block(success: false, radio: nil)
                }
            } else {
                //block(success: false, radio: nil)
            }
        })
    }
    
    func loadTermsPolicy() {
        print(Constants.WebServiceApi.getTermsPolicy)
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.getTermsPolicy, params: nil, completion: { (response, error) -> Void in
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
                        
                        SharedData.termsPolicyString = str1
                        print(str1)
                    }
                    
 
                } else {
                    //block(success: false, radio: nil)
                }
            } else {
                //block(success: false, radio: nil)
            }
        })
    }
    
    func loadAlarmString() {
        print(Constants.WebServiceApi.getAlarm)
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.getAlarm, params: nil, completion: { (response, error) -> Void in
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
                    
                    let posts = json["content"] as? NSArray
                    
                    if posts != nil {
                        let dic = posts![0] as? NSDictionary
                        //if dic != nil {
                        SharedData.alarmString = dic
                        //}
                        
                        
                    }
                    
 
                } else {
                    //block(success: false, radio: nil)
                }
            } else {
                //block(success: false, radio: nil)
            }
        })
        
    }
    
    func loadChangeContent() {
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
                        //self.webView.loadHTMLString(SharedData.changeDesignString!, baseURL: nil)
                    }
                    

                } else {
                    //block(success: false, radio: nil)
                }
            } else {
                //block(success: false, radio: nil)
            }
        })
        
    }  
   
    

}
