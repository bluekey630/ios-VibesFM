//
//  Constants.swift
//  Radio
//
//  Created by Admin on 11/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

public struct Constants {
    static let AppName = "Vibes FN"
    static let NetWorkOfflineMessage = "Internet connection is gone offline. Please check your network!"
    static let iTunesAppID = "959379869"
    
    static let RadioStationURL = "https://mobile.rohhat.com/radio/vibesfm/stream/appstream.pls"//"http://93.186.197.172:8000"//"http://streamplus22.leonex.de:21850/"
    static let RadioStationURL1 = "https://mobile.rohhat.com/radio/unitfm/stream/appstream.pls"//"http://93.186.197.172:8000"//"http://streamplus22.leonex.de:21850/"
    static let RadioLicenseKey = "your-license-key"
    
    static let CountryCode = "US"
    
    struct AdMob {
        static let Banner = "ca-app-pub-2418885570164107/2472701171"//"ca-app-pub-1521350466559542/1774430310"
        static let Interstitial = "ca-app-pub-6978221719193639/3934385486"
        static let Interstital_Interval = 3
    }
    
    struct SocialLink {
        static let Ads = "http://univeril.de/google/gapp.php"
        
        static let Facebook = "https://www.facebook.com/VIBESFMHAMBURG"
        static let Twitter = "https://twitter.com/RADIO_VIBES_FM"
        static let Website = "http://www.vibesfm.de"
        static let Info = "http://univeril.de/app_info/"
    }
    
    struct Colors {
        static let Main = UIColor(netHex: 0x282830)
        static let Green = UIColor(netHex: 0x1CB5A9)
        static let Red = UIColor(netHex: 0xf30A1A)
        static let Yellow = UIColor(netHex: 0xE8C318)
        static let Male = UIColor(netHex: 0x03A9F4)
        static let Female = UIColor(netHex: 0xF44336)
    }
    
    struct MainFontNames {
        static let Regular = "GothamRounded-Book"
        static let Light = "GothamRounded-Light"
        static let Bold = "GothamRounded-Bold"
        static let Medium = "GothamRounded-Medium"
    }
    
    struct Location_Persmission {
        static let DeviceNotAllow = 100
        static let AppNotAllow = 200
        static let Allow = 300
    }

    struct DeviceInfo {
        static let DefaultDeviceToken = "2222222"
        static let DeviceType = "ios"
    }
    
    struct DefaultIcons {
        static let Artist = "default_artist.png"
    }
    
    struct RadioState {
        static let Connecting = "Connecting"
        static let Buffering = "Buffering"
        static let Playing = "Playing"
        static let Stopped = "Stopped"
        static let Error = "Error"
    }
    
    struct RadioError {
        static let RadioErrorAudioQueueBufferCreate = "Audio buffers could not be created."
        static let RadioErrorAudioQueueCreate = "Audio queue could not be created.."
        static let RadioErrorAudioQueueEnqueue = "Audio queue enqueue failed."
        static let RadioErrorAudioQueueStart = "Audio queue could not be started."
        static let RadioErrorFileStreamGetProperty = "File stream get property failed."
        static let RadioErrorFileStreamOpen = "File stream could not be opened."
        static let RadioErrorPlaylistParsing = "Playlist could not be parsed."
        static let RadioErrorDecoding = "Audio decoding error."
        static let RadioErrorHostNotReachable = "Radio host not reachable."
        static let RadioErrorNetworkError = "Network connection error."
        static let RadioErrorUnsupportedStreamFormat = "Unsupported stream format."
    }
    
    struct WebServiceApi {
        static let GetInfo = "https://www.mobile.rohhat.com/radio/vibesfm/appcoming.php"//"http://www.vibesfm.de/VIBESFMHAMBURG/aj_TimeRemain.php"
        static let BaseArtistURL = "https://www.mobile.rohhat.com/radio/vibesfm/"//"http://www.vibesfm.de/arts_pics/"
        static let DefaultArtistURL = "http://www.mobile.rohhat.com/radio/vibesfm/album_art/default.jpg"//"http://www.vibesfm.de/VibesFMHH/album_art/default.jpg"
        static let SongHistory = "https://www.mobile.rohhat.com/radio/vibesfm/appcoming.php"
        static let getMenuItem = "https://www.mobile.rohhat.com/radio/vibesfm/json/menu.json"
        static let getContact = "https://www.mobile.rohhat.com/radio/vibesfm/json/contact.json"
        static let getFAQ = "https://www.mobile.rohhat.com/radio/vibesfm/json/faq.json"
        static let getImprint = "https://www.mobile.rohhat.com/radio/vibesfm/json/imprint.json"
        static let getTermsPolicy = "https://www.mobile.rohhat.com/radio/vibesfm/json/termsPolicy.json"
        static let getAlarm = "https://www.mobile.rohhat.com/radio/vibesfm/json/alarm_content.json"
        static let requestSong = "https://www.mobile.rohhat.com/radio/vibesfm/request.php"
        static let changeDesign = "https://www.mobile.rohhat.com/radio/vibesfm/json/designs.json"
        static let premiumNotice = "https://www.mobile.rohhat.com/radio/vibesfm/json/premium_shortnotice.json"
        static let GetInfo1 = "https://www.mobile.rohhat.com/radio/unitfm/appcoming.php"//"http://www.vibesfm.de/VIBESFMHAMBURG/aj_TimeRemain.php"
        static let BaseArtistURL1 = "https://www.mobile.rohhat.com/radio/unitfm/"//"http://www.vibesfm.de/arts_pics/"
        static let DefaultArtistURL1 = "http://www.mobile.rohhat.com/radio/unitfm/album_art/default.jpg"//"http://www.vibesfm.de/VibesFMHH/album_art/default.jpg"
        static let SongHistory1 = "https://mobile.rohhat.com/radio/unitfm/appcoming.php"
        static let getMenuItem1 = "https://www.mobile.rohhat.com/radio/unitfm/json/menu.json"
        static let getContact1 = "https://www.mobile.rohhat.com/radio/unitfm/json/contact.json"
        static let getFAQ1 = "https://www.mobile.rohhat.com/radio/unitfm/json/faq.json"
        static let getImprint1 = "https://www.mobile.rohhat.com/radio/unitfm/json/imprint.json"
        static let getTermsPolicy1 = "https://www.mobile.rohhat.com/radio/unitfm/json/termsPolicy.json"
        static let getAlarm1 = "https://www.mobile.rohhat.com/radio/unitfm/json/alarm_content.json"
        static let requestSong1 = "https://www.mobile.rohhat.com/radio/unitfm/request.php"
        static let changeDesign1 = "https://www.mobile.rohhat.com/radio/unitfm/json/designs.json"
    }
    
}
