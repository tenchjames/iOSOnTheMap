//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by James Tench on 8/30/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    
    func authenticateWithViewController(credentials: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // log in with udacity...maybe switch her for facebook login
        self.getSessionId(credentials) { success, udacityLogin, errorString in
            if success {
                self.sessionId = udacityLogin!.sessionId
                self.UserId = udacityLogin!.accountKey
                
                // now get the users info
                self.getUdacityUserInfo(self.UserId!) { success, udacityUser, errorString in
                    if success {
                        if let udacityStudent = udacityUser {
                            self.udacityStudent = udacityStudent
                            completionHandler(success: true, errorString: nil)
                        } else {
                            // if some reason the object is nil we have an error
                            completionHandler(success: false, errorString: "Error getting User info")
                        }
                    } else {
                        completionHandler(success: false, errorString: errorString)
                    }
                }
            } else {
                completionHandler(success: false, errorString: errorString)
            }
        }
    }
    
    func getSessionId(credentials: [String: AnyObject], completionHandler: (success: Bool, udacityLogin: UdacityLogin?, errorString: String?) -> Void) {
        // no parameters needed to get session id, only need login credentials
        let parameters = [String: AnyObject]()
        let task = taskForPostMethod(Methods.Session, parameters: parameters, jsonBody: credentials) {JSONBody, error in
            if let error = error {
                var errorMessage : String
                if let message = ApiHelper.errorForNSError(error) {
                    errorMessage = message
                } else {
                    errorMessage = "Login Error" // general message
                }
                completionHandler(success: false, udacityLogin: nil, errorString: errorMessage)
            } else if let loginError = JSONBody.valueForKey("error") as? String {
                completionHandler(success: false, udacityLogin: nil, errorString: loginError)
            } else {
                if let result = JSONBody as? [String: AnyObject] {
                    let udacityLogin = UdacityLogin(dictionary: result)
                    completionHandler(success: true, udacityLogin: udacityLogin, errorString: nil)
                }
            }
        }
    }
    
    func getUdacityUserInfo(userId: String, completionHandler: (success: Bool, udacityStudent: UdacityStudent?, errorString: String?) -> Void) {
        let parameters = [String: AnyObject]();
        var mutableMethod = UdacityClient.Methods.User
        mutableMethod = ApiHelper.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserId, value: userId)!

        let task = taskForGetMethod(mutableMethod, parameters: parameters) {JSONResult, error in
            if let error = error {
                var errorMessage : String
                if let message = ApiHelper.errorForNSError(error) {
                    errorMessage = message
                } else {
                    errorMessage = "Error getting User info" // general message
                }
                completionHandler(success: false, udacityStudent: nil, errorString: errorMessage)
            } else {
                if let result = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? [String: AnyObject] {
                    let udacityStudent = UdacityStudent(dictionary: result)
                    completionHandler(success: true, udacityStudent: udacityStudent, errorString: nil)
                }
            }
        }
    }
        
}