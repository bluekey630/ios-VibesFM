//
//  APIManager.swift
//  Radio
//
//  Created by Admin on 11/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kanna

let TheAPIManagerManager = APIManager.sharedInstance

class APIManager: NSObject {
    static let sharedInstance = APIManager()
    
    override init() {
        super.init()
    }

    func getSongHistory(block: (success: Bool, songs: [SongHistory]) -> Void) {
        var url = ""
        if SharedData.stationState == 0 {
            url = Constants.WebServiceApi.SongHistory
        }
        else {
            url = Constants.WebServiceApi.SongHistory1
        }
        WebServiceAPI.sendGetRequest(url, params: nil) { (response, error) in
            if (response != nil) {
                var arrayTitles: [String] = []
                
                let htmlString = String(data: response as! NSData, encoding: NSUTF8StringEncoding)
                
                if let doc = HTML(html: htmlString!, encoding: NSUTF8StringEncoding) {
                    print(doc.title)
                    
                    //get artist image link
                    for tdTag in doc.css("td") {
                        //if let cellpadding = tableTag["cellpadding"] {
                            //if (cellpadding == "2") {
                                if let contentDoc = HTML(html: tdTag.innerHTML!, encoding: NSUTF8StringEncoding) {
                                    //for tdTag in contentDoc.css("td") {
                                        let tdContent = tdTag.content
                                        arrayTitles.append(tdContent!)
                                    //}
                                }
                            //}
                       // }
                    }
                    
                    if arrayTitles.count < 2 {
                        block(success: false, songs: [])
                    }
                    else {
                    
                    for _ in 0 ..< arrayTitles.count-2  {
                        arrayTitles.removeAtIndex(0)
                    }
                    var arraySongs: [SongHistory] = []
                    
                    for var str in arrayTitles {
                        
                        var startTime = ""
                        
                        var songTitle = ""
                        var duration = ""
                        var artistName = ""
                        
                        str = str.stringByReplacingOccurrencesOfString("[", withString: "")
                        str = str.stringByReplacingOccurrencesOfString("]", withString: "")
                        str = str.stringByReplacingOccurrencesOfString("Play time started on: ", withString: "")
                        str = str.stringByReplacingOccurrencesOfString("Track Play Time: ", withString: "")
                        var items = str.componentsSeparatedByString(" - ")
                        
                        items[0] = items[0].substringToIndex(items[0].endIndex.predecessor())
                        items[0] = items[0].substringToIndex(items[0].endIndex.predecessor())
                        items[0] = items[0].substringToIndex(items[0].endIndex.predecessor())
                        startTime = items[0]
                        artistName = items[1]
                        let subitems = items.last!.componentsSeparatedByString(" • ")
                        songTitle = subitems[0]
                        duration = subitems[1]
                        
                        duration = duration.stringByReplacingOccurrencesOfString("00:", withString: "")
                        duration = duration.stringByReplacingOccurrencesOfString(" ", withString: "")
                        let song = SongHistory(artist: artistName, title: songTitle, duration: duration, time: startTime)
                        arraySongs.append(song)
                    }
                    
                    block(success: true, songs: arraySongs)
                    }
                    
                } else {
                    block(success: false, songs: [])
                }
            } else {
                block(success: false, songs: [])
            }
        }
    }
    
    func getRadioArtist(block: (success: Bool, artistImageLink: String, artistName: String, songTitle: String, remainingTime: Int, comingSoonImageLink: String, comingSoonName: String) -> Void) {
        var url = ""
        if SharedData.stationState == 0 {
            url = Constants.WebServiceApi.GetInfo
        }
        else {
            url = Constants.WebServiceApi.GetInfo1
        }
        WebServiceAPI.sendPostRequest(url, params: nil, completion: { (response, error) -> Void in
            if (response != nil) {
                let htmlString = String(data: response as! NSData, encoding: NSUTF8StringEncoding)
                
                var bFoundArtistImageLink: Bool = false
                var bFoundComingSoon: Bool = false
                var artistImageLink: String = ""
                var artistName: String = ""
                var songTitle: String = ""
                var remainingTime: Int = 0
                var comingSoonImageLink: String = ""
                var comingSoonName: String = ""
                
                if let doc = HTML(html: htmlString!, encoding: NSUTF8StringEncoding) {
                    print(doc.title)
                    
                    //get artist image link
                    for figureTag in doc.css("td") {
                        if let imgClass = figureTag["class"] {
                            if (imgClass.rangeOfString("playing_track") != nil) {
                            if let artistImageHTML = figureTag.innerHTML {
                                if let artistDoc = HTML(html: artistImageHTML, encoding: NSUTF8StringEncoding) {
                                
                                    for imageTag in artistDoc.css("img") {
                                    //if let imgClass = imageTag["class"] {
                                        //if (imgClass.rangeOfString("playing_track") != nil) {
                                            artistImageLink = imageTag["src"]!
                                            print("########### artist image link = \(artistImageLink)")
                                            
                                            bFoundArtistImageLink = true
                                            break
                                        //}
                                    //}
                                    }
                                
                                }
                            }
                            }
                            
                        }
                        
                        if (bFoundArtistImageLink) {
                            break
                        }
                    }
                    
                    //get artist name and song time, remaining time
                    for divTag in doc.css("div") {
                        if let divTagStyle = divTag["style"] {
                            if (divTagStyle.rangeOfString("color:#333;font-size:17px") != nil) {
                                let strRemainingTime = divTag.content!
                                
                                let durationItems = strRemainingTime.componentsSeparatedByString(":")
                                if (durationItems.count < 2) {
                                    remainingTime = 0
                                } else {
                                    var strDurationMin = durationItems[1].stringByReplacingOccurrencesOfString("(", withString: "")
                                    strDurationMin = strDurationMin.stringByReplacingOccurrencesOfString("\n", withString: "")
                                    strDurationMin = strDurationMin.stringByReplacingOccurrencesOfString(" ", withString: "")
                                    var strDurationSec = durationItems[2].stringByReplacingOccurrencesOfString(")", withString: "")
                                    strDurationSec = strDurationSec.stringByReplacingOccurrencesOfString("\n", withString: "")
                                    strDurationSec = strDurationSec.stringByReplacingOccurrencesOfString(" ", withString: "")
                                    remainingTime = Int(strDurationMin)! * 60 + Int(strDurationSec)!
                                    SharedData.maxTime = remainingTime
                                    
                                }

                            }
                        }
                        
                        if let divTagClassTitle = divTag["class"] {
                            if (divTagClassTitle == "artistname") {
                                
                                artistName = divTag.content!
                                print("########### artist name = \(artistName)")
                            }

                            if (divTagClassTitle == "title") {
                                songTitle = divTag.content!
                                print("########### song title = \(songTitle)")
                            }
                            
                            
                        }
                    }
                    var flag = false
                    //var startedTime = 0
                    for tdTag in doc.css("td") {
                        
                        if flag == true {
                            let date = NSDate()
                            let calendar = NSCalendar.currentCalendar()
                            let min = calendar.component(NSCalendarUnit.Minute, fromDate: date)
                            let sec = calendar.component(NSCalendarUnit.Second, fromDate: date)
                            let curTime = min * 60 + sec
                            let strTime = tdTag.content!
                            let items = strTime.componentsSeparatedByString(":")
                            var remainTime = curTime - (Int(items[1])!*60 + Int(items[2])!)
                            
                            if remainTime < 0 {
                                remainTime = remainTime + 600
                            }
                            
                            remainingTime = remainingTime - remainTime
                            
                            break
                        }
                        if tdTag.content != nil {
                            if tdTag.content == "WHEN IT STARTED" {
                                flag = true
                            }
                        }
                        
                    }
                    
                    //get coming soon part from the html response.
                    
                    for figureTag in doc.css("td") {
//                        if let imgClass = figureTag["class"] {
//                            if (imgClass.rangeOfString("playing_track") != nil) {
                                if let artistImageHTML = figureTag.innerHTML {
                                    if let artistDoc = HTML(html: artistImageHTML, encoding: NSUTF8StringEncoding) {
                                        
                                        for imageTag in artistDoc.css("img") {
                                            if let imgClass = imageTag["height"] {
                                                if (imgClass.rangeOfString("40") != nil) {
                                                    comingSoonImageLink = imageTag["src"]!
                                                    comingSoonName = figureTag.content!
                                                    comingSoonName = comingSoonName.stringByReplacingOccurrencesOfString("\n", withString: "")
                                                    print("########### ComingSoon artist image link = \(comingSoonImageLink)")
                                                    print("########### ComingSoon artist Name = \(comingSoonName)")
                                                    bFoundComingSoon = true
                                                    break
                                                }
                                            }
                                        }
                                        
                                    }
                                }
//                            }
//                            
//                        }
                        
                        if (bFoundComingSoon) {
                            break
                        }
                    }

                    /*
                     -----------------
                     Here is code
                     
                     -----------------
                    */
                }
                if remainingTime < 0 {
                    remainingTime = SharedData.maxTime
                }
                SharedData.valTime = remainingTime
                print("ShareData.valTime++++++++++++>\(SharedData.valTime)")
                print("Remaining Time =====================>\(remainingTime)")
                block(success: true, artistImageLink: artistImageLink, artistName: artistName, songTitle: songTitle, remainingTime: remainingTime, comingSoonImageLink: comingSoonImageLink, comingSoonName:comingSoonName)
            } else {
                block(success: false, artistImageLink: "", artistName: "", songTitle: "", remainingTime: 0, comingSoonImageLink: "album_art/default.jpg", comingSoonName:"")
            }
        })
    }
    /*
    func getRadioInfo(block: (success: Bool, radio: Radio?) -> Void) {
        WebServiceAPI.sendPostRequest(Constants.WebServiceApi.GetInfo, params: nil, completion: { (response, error) -> Void in
            if (response != nil) {
                let strResponse = String(data: response as! NSData, encoding: NSUTF8StringEncoding)
                
                if (strResponse != nil) {
                    let items = strResponse!.componentsSeparatedByString("|")
                    
                    let radio_id = items[0]
                    let radio_remaining_time = Int(items[1])!
                    let radio_title = items[2]
                    let radio_artist = items[3]
                    let radio_artist_logo = items[4]
                    
                    let radio_info = Radio(id: radio_id, remaing_time: radio_remaining_time, title: radio_title, artist_name: radio_artist, artist_logo: radio_artist_logo)
                    
                    block(success: true, radio: radio_info)
                } else {
                    block(success: false, radio: nil)
                }
            } else {
                block(success: false, radio: nil)
            }
        })
    }
    */
 
}
