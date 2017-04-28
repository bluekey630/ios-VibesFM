//
//  Objects.swift
//  Radio
//
//  Created by Admin on 12/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Radio {
    let id: String
    let remaing_time: Int
    let title: String
    let artist_name: String
    let artist_logo: String
    
    init(id: String, remaing_time: Int, title: String, artist_name: String, artist_logo: String) {
        self.id = id
        self.remaing_time = remaing_time
        self.title = title
        self.artist_name = artist_name
        self.artist_logo = artist_logo
    }
}

struct SongHistory {
    let artist: String
    let title: String
    let duration: String
    let time: String
    
    init(artist: String, title: String, duration: String, time: String) {
        self.artist = artist
        self.title = title
        self.duration = duration
        self.time = time
    }
}
