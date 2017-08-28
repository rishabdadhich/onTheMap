//
//  studentsInfo.swift
//  onTheMap
//
//  Created by Rishabh on 01/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation

struct studentsInfo {
    static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let restKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    var firstName : String
    var lastName : String
    var createdAt : String
    var UpdatedAt : String
    var mediaURL : String
    var uniqueKey : String
    var objectID : String
    var mapString : String
    var latitude : Float
    var longitude : Float
    
    init?(dictionary: [String:AnyObject]) {
        guard let firstNAME = dictionary["firstName"] as? String else{
            return nil
        }
        firstName = firstNAME
        
        guard let lastNAME = dictionary["lastName"] as? String else {
            return nil
        }
        lastName = lastNAME
        
        guard let cretedAT = dictionary["createdAt"] as? String else {
            return nil
        }
        createdAt = cretedAT
        
        guard let updateAT = dictionary["updatedAt"] as? String else {
            return nil
        }
        UpdatedAt = updateAT
        
        guard let media = dictionary["mediaURL"] as? String else {
            return nil
        }
        mediaURL = media
        
        guard let unique = dictionary["uniqueKey"] as? String else {
            return nil
        }
        uniqueKey = unique
        
        guard let object = dictionary["objectId"] as? String else {
            return nil
        }
        objectID = object
        
        guard let map = dictionary["mapString"] as? String else {
            return nil
        }
        mapString = map
        
        guard let lat = dictionary["latitude"] as? Float else {
            return nil
        }
        latitude = lat
        
        guard let long = dictionary["longitude"] as? Float else {
            return nil
        }
        longitude = long

}
    static func studentFromResult(results:[[String:AnyObject]]) -> [studentsInfo]{
        var studentResult = [studentsInfo]()
        
        for student in results{
            if let eachStudent = studentsInfo(dictionary: student){
             studentResult.append(eachStudent)
           }
        }
        return studentResult
    }
}
