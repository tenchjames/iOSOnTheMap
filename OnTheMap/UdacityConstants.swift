//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by James Tench on 8/30/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation


extension UdacityClient {

    struct Constants {
        // udacity's url
        static let BaseSecureURL = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        
        static let Session = "session"
        static let User = "users/{id}"
    }
    
    struct URLKeys {
        static let UserId = "id"
    }
    
    struct JSONBodyKeys {
        static let UserName = "username"
        static let Password = "password"
        static let Access = "access_token"
    }
    
    struct JSONResponseKeys {
        // session keys
        static let Session = "session"
        static let SessionId = "id"
        static let SessionExpires = "expiration"
        
        // account keys
        static let Account = "account"
        static let AccountRegistered = "registered"
        static let AccountKey = "key"
        
        // user keys
        static let User = "user"
        static let UserLastName = "last_name"
        static let UserFirstName = "first_name"
        static let UserKey = "key"
        static let UserEmail = "email"
        static let UserEmailAddress = "address"
        
    }
    
}