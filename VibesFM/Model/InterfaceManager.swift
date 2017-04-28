//
//  ConstantManager.swift
//  Radio
//
//  Created by Admin on 11/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

let TheInterfaceManager = InterfaceManager.sharedInstance

extension UIImageView {
    func downloadedFrom(link link:String, indicatorStyle: UIActivityIndicatorViewStyle, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
        let loadingActivity = UIActivityIndicatorView(activityIndicatorStyle: indicatorStyle)
        loadingActivity.tag = 10
        loadingActivity.frame = self.bounds
        self.addSubview(loadingActivity)
        loadingActivity.startAnimating()
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else
                {
                    loadingActivity.stopAnimating()
                    loadingActivity.removeFromSuperview()
                    return
                }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                loadingActivity.stopAnimating()
                loadingActivity.removeFromSuperview()
                self.image = image
            }
        }).resume()
    }
}

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate//Your app delegate class name.
extension UIApplication {
    class func topViewController(base: UIViewController? = appDelegate.window!.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

class InterfaceManager: NSObject, UIAlertViewDelegate {
    static let sharedInstance = InterfaceManager()
    var resultAlertView:UIAlertView?
    var appName:String = ""

    var bTappedMenu: Bool = false
    
    let mainColor:UIColor = UIColor(red: 77.0/255.0, green: 181.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    let borderColor:UIColor = UIColor(red: 151.0 / 255.0, green: 151.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
    let naviTintColor:UIColor = UIColor(red: 252.0/255.0, green: 110.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    
    override init() {
        super.init()
        let bundleInfoDict: NSDictionary = NSBundle.mainBundle().infoDictionary!
        appName = bundleInfoDict["CFBundleName"] as! String
    }
    
    func deviceHeight ()-> CGFloat{
        return UIScreen.mainScreen().bounds.size.height
    }
    
    func deviceWidth () -> CGFloat{
        return UIScreen.mainScreen().bounds.size.width
    }
    
    func showLocalValidationError(errorMessage:String)-> Void{
        if let _ = resultAlertView {
            
        } else {
            let title:String = "\(appName) Error"
            resultAlertView = UIAlertView(title: title, message: errorMessage, delegate: self, cancelButtonTitle: "OK")
            resultAlertView!.show()
        }
    }
    
    func showLocalValidationError(title:String, errorMessage:String)-> Void{
        if let _ = resultAlertView {
            
        } else {
            resultAlertView = UIAlertView(title: title, message: errorMessage, delegate: self, cancelButtonTitle: "OK")
            resultAlertView!.show()
        }
    }
    
    func showSuccessMessage (successMessage:String)-> Void{
        if let _ = resultAlertView {
            
        } else {
            resultAlertView = UIAlertView(title: appName as String, message: successMessage, delegate: self, cancelButtonTitle: "OK")
            resultAlertView!.show()
        }
    }
    
    //MARK: - Navigation Bar
    func setNavigationBarTransparentTo(navigationController:UINavigationController?) {
        if let navigationController = navigationController {
            let clearImage = InterfaceManager.imageWithColor(UIColor.clearColor())
            navigationController.navigationBar.setBackgroundImage(clearImage, forBarMetrics: UIBarMetrics.Default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.backgroundColor = UIColor.clearColor()
            navigationController.navigationBar.translucent = true
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
            
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        }
    }
    
    func setNavigationBarWithTintColor(navigationController:UINavigationController?) {
        if let navigationController = navigationController {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.lightGrayColor()
            shadow.shadowOffset = CGSizeMake(0, 0)
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
            navigationController.navigationBar.barTintColor = naviTintColor
            navigationController.navigationBar.translucent = false
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
    }
    
    static func addShadowEffectToView(view: UIView, shadowSize size:CGFloat, yOffset: CGFloat, withColor shadowColor:UIColor) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = shadowColor.CGColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSizeMake(0, yOffset)
        view.layer.shadowRadius = size
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).CGPath
        view.layer.shouldRasterize = true
    }
    
    static func doPopUpAnimation (view: UIView, needAlpha: Bool, completed: () -> Void) {
        if view.hidden == true {
            view.transform = CGAffineTransformMakeScale(0.6, 0.6);
        }
        
        view.hidden = false
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            view.alpha = 0.8
            },
                                   completion: {(bCompleted) -> Void in
                                    UIView.animateWithDuration(2/15.0, animations: {() -> Void in
                                        view.transform = CGAffineTransformMakeScale(0.7, 0.7)
                                        view.alpha = 0.9
                                        },
                                        completion: {(bCompleted) -> Void in
                                            UIView.animateWithDuration(2/7.5, animations: {() -> Void in
                                                view.transform = CGAffineTransformIdentity
                                                view.alpha = 1.0
                                                if (needAlpha) {
                                                    view.alpha = 0.3
                                                }
                                                },
                                                completion: {(bCompleted) -> Void in
                                                    if (bCompleted) {
                                                        completed()
                                                    }
                                            })
                                    })
                                    
        })
    }

    static func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context!, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context!, flipVertical)
        CGContextDrawImage(context!, newRect, image.CGImage!)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context!)!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func imageWithColor(color:UIColor) -> UIImage {
        let rect:CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func changeFontAndColorInSearchBar(searchBar: UISearchBar, textColor: UIColor, font: UIFont) {
        let textFieldInsideUISearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = textColor
        textFieldInsideUISearchBar?.font = font
    }
    
    static func showToastView(title: String) {
        JLToast.makeText(title, duration: 2.0).show()
    }
    
    static func showLoadingView(view: UIView,	 title: String) {
        let loadingView = MBProgressHUD.init(view: view)
        view.addSubview(loadingView)
        
        loadingView.tag = 1200
        loadingView.labelText = title
        loadingView.labelColor = UIColor.whiteColor()
        loadingView.labelFont = UIFont(name: Constants.MainFontNames.Regular, size: 13.0)
        loadingView.dimBackground = true
        
        loadingView.show(true)
    }
    
    static func hideLoadingView(view: UIView) {
        var loadingView = view.viewWithTag(1200) as? MBProgressHUD
        if (loadingView != nil) {
            loadingView?.hide(true)
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
    }

    static func makeRadiusControl(view:UIView, cornerRadius radius:CGFloat, withColor borderColor:UIColor, borderSize borderWidth:CGFloat) {
        view.layer.cornerRadius = radius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.CGColor
        view.layer.masksToBounds = true
    }
    
    static func addBorderToView(view:UIView, toCorner corner:UIRectCorner, cornerRadius radius:CGSize, withColor borderColor:UIColor, borderSize borderWidth:CGFloat) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: radius)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path  = maskPath.CGPath
        
        view.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = view.bounds
        borderLayer.path  = maskPath.CGPath
        borderLayer.lineWidth   = borderWidth
        borderLayer.strokeColor = borderColor.CGColor
        borderLayer.fillColor   = UIColor.clearColor().CGColor
        borderLayer.setValue("border", forKey: "name")
        
        if let sublayers = view.layer.sublayers {
            for prevLayer in sublayers {
                if let name: AnyObject = prevLayer.valueForKey("name") {
                    if name as! String == "border" {
                        prevLayer.removeFromSuperlayer()
                    }
                }
            }
        }
        
        view.layer.addSublayer(borderLayer)
    }
    
    //MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        resultAlertView = nil
    }
    
    // MARK: - Others
    func sizeOfString (string: String, constrainedToWidth width: Double, font:UIFont) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size
    }
    
}
