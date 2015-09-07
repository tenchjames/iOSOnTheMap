//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by James Tench on 9/3/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation

struct UdacityLogin {
    var accountKey = ""
    var registered : Bool = false
    var sessionId : String = "notvalid"
    var sessionExpiration : String = "expired";
    
    init(dictionary: [String: AnyObject]) {
        if let account = dictionary[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] {
            if let key = account[UdacityClient.JSONResponseKeys.AccountKey] as? String {
                self.accountKey = key;
            }
            if let isRegistered = account[UdacityClient.JSONResponseKeys.AccountRegistered] as? Bool {
                self.registered = isRegistered
            }
        }
        
        if let session = dictionary[UdacityClient.JSONResponseKeys.Session] as? [String: AnyObject] {
            if let currentSessionId = session[UdacityClient.JSONResponseKeys.SessionId] as? String {
                self.sessionId = currentSessionId
            }
            
            if let expires = session[UdacityClient.JSONResponseKeys.SessionExpires] as? String {
                sessionExpiration = expires
            }
        }
    }    
}