//
//  WebServiceAPI.swift
//  Radio
//
//  Created by Admin on 11/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WebServiceAPI: NSObject {
     static func sendPostRequest(url:String, params: [String : AnyObject]?, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            print("\(response.response?.statusCode)")
            if (response.response?.statusCode == 200) {
                completion(response: response.data, error: nil)
            } else {
                completion(response: nil, error: nil)
            }
            /*
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                completion(response: nil, error: error)
            }
            */
        }
    }

    static func sendGetRequest(url:String, params: [String : AnyObject]?, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            print("\(response.response?.statusCode)")
            if (response.response?.statusCode == 200) {
                completion(response: response.data, error: nil)
            } else {
                completion(response: nil, error: nil)
            }
        }
    }

    /*
    static func sendGetRequest(url:String, params: [String : AnyObject]?, completion: (response: AnyObject?, error: NSError?) -> Void)
    {
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            response in
            switch response.result {
            case .Success:
                completion(response: response.result.value, error: nil)
            case .Failure(let error):
                completion(response: nil, error: error)
            }
        }
    }
    */

}
