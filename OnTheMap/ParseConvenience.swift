//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by James Tench on 9/3/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation


extension ParseClient {
    
    func getMostRecentStudentLocations(parameters: [String: AnyObject], completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
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
    
    func postNewStudentLocation(studentInformation: StudentInformation, completionHandler: (result: String?, error: NSError?) -> Void) {
        let method = ParseClient.Methods.StudentLocation
        
        let parameters = [:]
        let jsonBody: [String: AnyObject] = [
            ParseClient.JSONResponseKeys.UniqueKey : studentInformation.uniqueKey,
            ParseClient.JSONResponseKeys.FirstName : studentInformation.firstName,
            ParseClient.JSONResponseKeys.LastName : studentInformation.lastName,
            ParseClient.JSONResponseKeys.MapString : studentInformation.mapString,
            ParseClient.JSONResponseKeys.MediaURL : studentInformation.mediaUrl,
            ParseClient.JSONResponseKeys.Latitude : studentInformation.latitude,
            ParseClient.JSONResponseKeys.Longitude : studentInformation.longitude
        ]
        taskForPostMethod(method, jsonBody: jsonBody) { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let newObjectId = JSONResult.valueForKey(ParseClient.JSONResponseKeys.ObjectId) as? String {
                    completionHandler(result: newObjectId, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "postNewStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postNewStudentLocation"]))
                }
            }
            
        }
    }
    
}