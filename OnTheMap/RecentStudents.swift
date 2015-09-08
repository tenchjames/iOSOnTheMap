//
//  RecentStudents.swift
//  OnTheMap
//
//  Created by James Tench on 9/7/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import Foundation


class RecentStudents {
  
    var mostRecentStudentLocations: [StudentInformation] = [StudentInformation]()
    
    func loadFromJSONResults(results: [[String: AnyObject]]) {
        mostRecentStudentLocations = StudentInformation.studentsFromResuls(results)
    }
    
    func loadFromStudentArray(students: [StudentInformation]) {
        mostRecentStudentLocations = students
    }
    
    func appendStudents(students: [StudentInformation]) {
        mostRecentStudentLocations += students
    }
    
    func prependStudents(students: [StudentInformation]) {
        var newStudentIndex = students.count - 1
        for newStudentIndex; newStudentIndex > 0; newStudentIndex-- {
            mostRecentStudentLocations.insert(students[newStudentIndex], atIndex: 0)
        }
    }
    
    func prependStudent(student: StudentInformation) {
        mostRecentStudentLocations.insert(student, atIndex: 0)
    }
    
    func getRecentStudents() -> [StudentInformation] {
        return self.mostRecentStudentLocations
    }
    
    class func sharedInstance() -> RecentStudents {
        struct Singleton {
            static var sharedInstance = RecentStudents()
        }
        return Singleton.sharedInstance
    }
}


