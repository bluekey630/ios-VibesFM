//
//  RequestViewController.swift
//  VibesFM
//
//  Created by Admin on 4/18/17.
//  Copyright © 2017 Yury. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kanna

class RequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var artistArray:NSMutableArray?
    var titleArray:NSMutableArray?
    var songIDArray:NSMutableArray?
    
    var filteredArtistArray:NSMutableArray?
    var filteredTitleArray:NSMutableArray?
    var filteredSongIDArray:NSMutableArray?
    
    var curSongID:String?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var msgText: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.artistArray = NSMutableArray()
        self.titleArray = NSMutableArray()
        self.songIDArray = NSMutableArray()
        loadSong()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = "Request-View"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        self.backView.hidden = true
        self.msgView.hidden = true
    }

    func loadSong() {
        var url = ""
        if SharedData.state == 0 {
            url = Constants.WebServiceApi.requestSong
        }
        else {
            url = Constants.WebServiceApi.requestSong1
        }
        WebServiceAPI.sendPostRequest(url, params: nil, completion: { (response, error) -> Void in
            if (response != nil) {
                let htmlString = String(data: response as! NSData, encoding: NSUTF8StringEncoding)
                if htmlString == nil {
                    return
                }
                let strResponse = String(data: response as! NSData, encoding: NSUTF8StringEncoding)
                if let doc = HTML(html: htmlString!, encoding: NSUTF8StringEncoding) {
                    
                    for tr in doc.css("tr") {
                        if let item = tr.innerHTML {
                            if let tdDoc = HTML(html: item, encoding:NSUTF8StringEncoding) {
                                //var en = false
                                var cnt = 0
                                for td in tdDoc.css("td") {
                                    if cnt == 0 {
                                        if td["class"] != "entry_no" {
                                            break
                                        }
                                    }
                                    
                                    
                                    if cnt == 1 {
                                        self.artistArray!.addObject((td.content! as? String)!)
                                    }
                                    else if cnt == 2 {
                                        self.titleArray!.addObject((td.content! as? String)!)
                                    }
                                    else if cnt == 0 {
                                        self.songIDArray!.addObject((td.content! as? String)!)
                                    }
                                    cnt += 1
                                }
                            }
                        }
                    }

                }
                
                self.tableView.reloadData()
                if (strResponse != nil) {
                    
                } else {
//                    block(success: false, radio: nil)
                }
            } else {
//                block(success: false, radio: nil)
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" {
            return (self.filteredArtistArray?.count)!
        }
        return (self.artistArray?.count)!
        //return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RequestTableViewCell", forIndexPath: indexPath) as! RequestTableViewCell
        if searchBar.text != "" {
            cell.artistName.text = self.filteredArtistArray![indexPath.row] as? String
            cell.title.text = self.filteredTitleArray![indexPath.row] as? String
        }
        else{
            cell.artistName.text = self.artistArray![indexPath.row] as? String
            cell.title.text = self.titleArray![indexPath.row] as? String
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("OK")
        if self.searchBar.text == "" {
            curSongID = songIDArray![indexPath.row] as? String
            titleLabel.text = "Song request: \(artistArray![indexPath.row]) - \(titleArray![indexPath.row])"
        }
        else {
            curSongID = filteredSongIDArray![indexPath.row] as? String
            titleLabel.text = "Song request: \(filteredArtistArray![indexPath.row]) - \(filteredTitleArray![indexPath.row])"
        }
        
        backView.hidden = false
        msgView.hidden = false
        nameText.text = ""
        msgText.text = ""
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        filterContentForSearchText(searchBar.text!)
        tableView.reloadData()
        view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar.text!)
        tableView.reloadData()

    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
        tableView.reloadData()
    }
    
    
    func filterContentForSearchText(searchText: String) {
        if self.artistArray == nil {
            return
        }
        self.filteredArtistArray = NSMutableArray()
        self.filteredTitleArray = NSMutableArray()
        var cnt = 0
        for item in self.artistArray! {
            if item.lowercaseString.containsString(searchText.lowercaseString) {
                self.filteredArtistArray!.addObject(item)
                self.filteredTitleArray!.addObject(self.titleArray![cnt])
                self.filteredSongIDArray!.addObject(self.songIDArray![cnt])
            }
            cnt += 1
        }
        
        cnt = 0
        for item in self.titleArray! {
            if item.lowercaseString.containsString(searchText.lowercaseString) {
                self.filteredTitleArray!.addObject(item)
                self.filteredArtistArray!.addObject(self.artistArray![cnt])
                self.filteredSongIDArray!.addObject(self.songIDArray![cnt])
            }
            cnt += 1
        }
    }
    
    
    @IBAction func tappedScreen(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func tappedOK(sender: AnyObject) {
        if nameText.text?.length == 0 {
            print("please input Name!")
            let alertController = UIAlertController(title: "ERROR", message: "Please enter name!", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "Retry", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            let req:[String:AnyObject] = ["requsername" : nameText.text!, "reqmessage":msgText.text!,"reqsubmit":"Submit Your Request","songID":curSongID!]
            var url = ""
            if SharedData.state == 0 {
                url = "https://www.mobile.rohhat.com/radio/vibesfm/request.php?page=1"
            }
            else {
                url = "https://mobile.rohhat.com/radio/unitfm/request.php?page=1&requestid=3"
            }
            WebServiceAPI.sendPostRequest(url, params: req, completion: { (response, error) -> Void in
                if (response != nil) {
                        
                   print("Song Req is OK")
                } else {
                    print("Net is bad")
                }
            })
            
            backView.hidden = true
            msgView.hidden = true
        }
        
    }
    
    @IBAction func tappedCancel(sender: AnyObject) {
        backView.hidden = true
        msgView.hidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 1 {
            msgText.becomeFirstResponder()
        }
        else if textField.tag == 2 {
            view.endEditing(true)
        }
        return true
    }
    
    
}
