//
//  UdacityStudent.swift
//  OnTheMap
//
//  Created by James Tench on 9/3/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation

// for extracting app student info from JSON user response

struct UdacityStudent {
    var lastName : String? = nil
    var firstName : String? = nil
    var emailAddress : String? = nil
    
    init(dictionary: [String: AnyObject]) {
        if let userLastName = dictionary[UdacityClient.JSONResponseKeys.UserLastName] as? String {
            self.lastName = userLastName
        }
        
        if let userFirstName = dictionary[UdacityClient.JSONResponseKeys.UserFirstName] as? String {
            self.firstName = userFirstName
        }
        
        if let emailObject = dictionary[UdacityClient.JSONResponseKeys.UserEmail] as? [String: AnyObject] {
            if let email = emailObject[UdacityClient.JSONResponseKeys.UserEmailAddress] as? String {
                self.emailAddress = email;
            }
        }
    }
}