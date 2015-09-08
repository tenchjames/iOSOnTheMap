//
//  ParseStudentLocation.swift
//  OnTheMap
//
//  Created by James Tench on 9/3/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation


struct StudentInformation {
    var objectId = ""
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaUrl = ""
    var latitude = 0.0
    var longitude = 0.0
    var createdAt = ""
    
    init (dictionary: [String: AnyObject]) {
        if let objectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as? String {
            self.objectId = objectId
        }
        
        if let uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }
        
        if let firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String {
            self.firstName = firstName
        }
        
        if let lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String {
            self.lastName = lastName
        }
        
        if let mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String {
            self.mapString = mapString
        }
        
        if let mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String {
            self.mediaUrl = mediaURL
        }
        
        if let latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double {
            self.longitude = longitude
        }
        
        if let createdAt = dictionary[ParseClient.JSONResponseKeys.CreatedAt] as? String {
            self.createdAt = createdAt
        }
    }
    
    static func studentsFromResuls(results: [[String: AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        return students
    }
    
    
    
}


























