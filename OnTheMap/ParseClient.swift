//
//  ParseClient.swift
//  OnTheMap
//
//  Created by James Tench on 9/3/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    // shared session
    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - GET
    func taskForGetMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. set parameters
        var mutableparameters = parameters
        
        // 2. build the url
        let urlString = Constants.BaseSecureURL + method + ApiHelper.escapedParameters(mutableparameters)
        let url = NSURL(string: urlString)!
        
        // 3. configure request
        let request = NSMutableURLRequest(URL: url)
        request.addValue(ParseClient.ParseApiKeys.ParseApplicationId, forHTTPHeaderField: ParseClient.JSONHeaderValues.ApplicationHeader)
        request.addValue(ParseClient.ParseApiKeys.ParseRestApiKey, forHTTPHeaderField: ParseClient.JSONHeaderValues.RestApiKeyHeader)
        // 4. make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                // 5. & 6. Parse the data and use (send with completion handler)
                ApiHelper.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        // 7. start the task
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    func taskForPostMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. set the parameters
        // none needed for Parse post
        
        // 2. build the url
        let urlString = Constants.BaseSecureURL + method
        let url = NSURL(string: urlString)!
        
        // 3. configure the request
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(ParseClient.ParseApiKeys.ParseApplicationId, forHTTPHeaderField: ParseClient.JSONHeaderValues.ApplicationHeader)
        request.addValue(ParseClient.ParseApiKeys.ParseRestApiKey, forHTTPHeaderField: ParseClient.JSONHeaderValues.RestApiKeyHeader)
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            // 5. & 6. pars and use the data (completion handler)
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                ApiHelper.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
            
        }
        task.resume()
        return task
    }
    
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
}
