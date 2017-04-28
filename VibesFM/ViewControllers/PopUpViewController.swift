//
//  PopUpViewController.swift
//  VibesFM
//
//  Created by Admin on 25/01/2017.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit

protocol PopUpViewControllerDelegate {
    func actionDismissViewCon(viewCon: PopUpViewController)
}

class PopUpViewController: UIViewController, UIWebViewDelegate {
    var delegate: PopUpViewControllerDelegate? = nil
    
    var bLoadedView: Bool = false
    
    var m_strWebSiteLink: String = ""
    
    @IBOutlet weak var m_viewPopUp: UIView!
    @IBOutlet weak var m_webView: UIWebView!
    @IBOutlet weak var m_loadingActivity: UIActivityIndicatorView!
    
    //var indicator: MaterialLoadingIndicator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = "Popup-View"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        InterfaceManager.makeRadiusControl(self.m_webView, cornerRadius: 10.0, withColor: UIColor.clearColor(), borderSize: 0.0)
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        self.loadWebPage()
        
        self.m_viewPopUp.hidden = true
        InterfaceManager.doPopUpAnimation(self.m_viewPopUp, needAlpha: false, completed: { () -> Void in
        })
    }
    
    func loadWebPage() {
        self.m_webView.delegate = self
        self.m_webView.loadRequest(NSURLRequest(URL: NSURL(string: self.m_strWebSiteLink)!))
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.m_loadingActivity.hidden = false
        self.m_loadingActivity.startAnimating()

        /*
        indicator = MaterialLoadingIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        indicator!.center = CGPoint(x: CGRectGetWidth(self.view.bounds) / 2.0, y: CGRectGetHeight(self.view.bounds) / 2.0)
        view.addSubview(indicator!)
        indicator!.startAnimating()
        */
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        /*
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
        */
        
        self.m_loadingActivity.stopAnimating()
        self.m_loadingActivity.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionCancel(sender: AnyObject) {
        if (self.delegate != nil) {
            self.delegate?.actionDismissViewCon(self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
