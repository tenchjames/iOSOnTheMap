//
//  ApiHelper.swift
//  OnTheMap
//
//  Created by James Tench on 8/29/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation
import UIKit


class ApiHelper {

    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    
    /* Helper: Given and NSError, check for error string to display */
    class func errorForNSError(error: NSError) -> String? {
        if let userInfo = error.userInfo as? [String: AnyObject] {
            if let customMessage = userInfo["NSLocalizedDescription"] as? String{
                return customMessage
            }
        }
        return nil
    }
    
    class func displayErrorAlert(hostController: UIViewController, title: String, message: String) {
        let controller = UIAlertController();
        controller.title = title
        controller.message = message
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { action in
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
        controller.addAction(dismissAction)
        hostController.presentViewController(controller, animated: true, completion: nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper to check for valid url...not perfect but gets general form */
    class func isValidURL(testURL: String) -> Bool {
        let regex = NSRegularExpression(pattern: "^http(s)?://[a-zA-Z0-9]+", options: .allZeros, error: nil)
        let range = NSMakeRange(0, count(testURL))
        return regex?.firstMatchInString(testURL, options: .allZeros, range: range) != nil
    }
    
    /* email helper - found on stack overflow */
    class func isValidEmail(email: String) -> Bool {
        let regex = NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(email, options: nil, range: NSMakeRange(0, count(email))) != nil
    }
    
    
}