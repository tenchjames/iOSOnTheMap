//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by James Tench on 9/3/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation


extension ParseClient {
    struct Constants {
        // udacity's url
        static let BaseSecureURL = "https://api.parse.com/1/classes/"
    }
    
    struct Methods {
        static let StudentLocation = "StudentLocation"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    struct ParameterValues {
        static let CreatedAtAsc = "createdAt"
        static let CreatedAtDesc = "-createdAt"
    }
    
    struct JSONHeaderValues {
        static let ApplicationHeader = "X-Parse-Application-Id"
        static let RestApiKeyHeader = "X-Parse-REST-API-Key"
    }
    
    struct ParseApiKeys {
        static let ParseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // body uses some response keys
    struct JSONResponseKeys {
        static let Results = "results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
    }
    
}