//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by James Tench on 9/3/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation


extension ParseClient {
    
    func getMostRecentStudentLocations(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        let parameters = [
            ParseClient.ParameterKeys.Limit: 100
        ]
        
        let method = ParseClient.Methods.StudentLocation
        taskForGetMethod(method, parameters: parameters) { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, error: error);
            } else {
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String: AnyObject]] {
                    var studentLocations = StudentInformation.studentsFromResuls(results)
                    completionHandler(result: studentLocations, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "Get Most Recent Locations parse error", code: 0, userInfo:[NSLocalizedDescriptionKey: "Could not parse getMostRecentStudentLocations"]))
                }
            }
        }
    }
}