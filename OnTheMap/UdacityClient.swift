//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by James Tench on 8/30/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation


class UdacityClient : NSObject {
    
    // shared session
    var session: NSURLSession
    
    var sessionId: String?  = nil
    var UserId: String? = nil
    var facebookLogin : Bool = false
    
    var udacityStudent: UdacityStudent? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    func taskForGetMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. set parameters
        var mutableparameters = parameters
        
        // 2. build the url
        let urlString = Constants.BaseSecureURL + method + ApiHelper.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        // 3. configure request
        let request = NSURLRequest(URL: url)
        // 4. make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                // TODO: create error messaging
                //let userInfo = [NSLocalizedDescriptionKey : "Need to get error from JSON"]
                //let newError = NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
                completionHandler(result: nil, error: error)
            } else {
                // 5. & 6. Parse the data and use (send with completion handler)
                // needed to trim udacity api string padding
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                ApiHelper.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        // 7. start the task
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    func taskForPostMethod(method: String, parameters: [String : AnyObject], jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // 1. set the parameters
        var mutableParameters = parameters
        
        // 2. build the url
        let urlString = Constants.BaseSecureURL + method + ApiHelper.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        // 3. configure the request
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            // 5. & 6. pars and use the data (completion handler)
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                // needed to trim udacity api string padding
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                ApiHelper.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
            
        }
        task.resume()
        return task
    }
    


    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}