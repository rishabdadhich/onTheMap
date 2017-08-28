//
//  parsingData.swift
//  onTheMap
//
//  Created by Rishabh on 02/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation

class parsingData{
    
    //Mark: shared instance
    
    class func sharedInstance() -> parsingData{
        struct singleton{
            static var sharedInstance = parsingData()
        }
        return singleton.sharedInstance
    }
    
    //Mark: get multiple student locations
    
    func  getStudentsLocation (completionHandlerForGetStudentsLocation: @escaping (_ success:Bool? ,_ error:String?) -> Void){
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(studentsInfo.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(studentsInfo.restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func displayError(_ error:String){
                print(error)
                completionHandlerForGetStudentsLocation(false, error)
            }
            
            guard error == nil else{
                displayError("error found in first ")
                return
            }
            
            guard let data = data else{
                displayError("error found , data empty")
                return
            }
            
            if let parsedData = (try! JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:AnyObject]{
                
                guard error == nil else{
                    displayError("not able to get user location")
                    return
                }
                
                if (parsedData["results"] != nil){
                    studentDict.sharedInstance.studentsDict = studentsInfo.studentFromResult(results: parsedData["results"] as! [[String:AnyObject]])
                    
                    completionHandlerForGetStudentsLocation(true, nil)
                }
                else
                {
                    displayError("not able to get the user location")
                }
            }
            else
            {
                completionHandlerForGetStudentsLocation(false, error?.localizedDescription)
            }
            
        }
        task.resume()
        
    }
    
    //Mark: get user location
    
    func getUserLocation(_ userIDUniqueKey: String , completionHandlerForGetUserLocation:@escaping(_ success:Bool? ,_ error:String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(userIDUniqueKey)%22%7D")!)
        request.addValue(studentsInfo.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(studentsInfo.restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest){data ,response , error in
            
            func displayError(_ error:String){
                print(error)
                completionHandlerForGetUserLocation(false, error)
            }
            guard error == nil else{
                displayError("error found in get user location")
                return
            }
            
            guard let data = data else{
                displayError("error found , data empty")
                return
            }
            
            if let parderData = (try! JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:AnyObject] {
                
                guard error == nil else{
                    displayError("error found, not able to get user location")
                    return
                }
                
                let userLocationAttributes = parderData["results"] as? [[String:AnyObject]]
                
                guard error == nil else{
                    displayError("error found ,  not able to find user location")
                    return
                }
                
                if let userMap = userLocationAttributes?.last?["mapString"] as? String{
                    userInfo.userMapString = userMap
                    
                }
                if let URLStatus = userLocationAttributes?.last?["mediaURL"] as? String{
                    userInfo.userURLStatus = URLStatus
                }
                if let objectId = userLocationAttributes?.last?["objectID"] as? String{
                    userInfo.objectId = objectId
                }
                if let lat = userLocationAttributes?.last?["latitude"] as? Double {
                    userInfo.mapLatitude = lat
                }
                if let long = userLocationAttributes?.last?["longitude"] as? Double{
                    userInfo.mapLongitude = long
                }
                completionHandlerForGetUserLocation(true, nil)
            }
            else{
                completionHandlerForGetUserLocation(false, error?.localizedDescription)
            }
            
            
        }
        task.resume()
        
    }
    
    //Mark: post user location
    
    func postUserLocation(userIDUniqueKey:String, firstName:String,lastName:String, mapString:String, mediaURL:String, latitude:Double, longitude:Double, completionHandlerForPostUserLocation:@escaping(_ success:Bool?,_ error:String? ) -> Void){
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        
        request.httpMethod = "POST"
        // Pass both Application & Rest API Keys
        request.addValue(studentsInfo.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(studentsInfo.restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(userIDUniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest){data, response, error in
            
            guard error == nil else{
                print("error found")
                completionHandlerForPostUserLocation(false, error?.localizedDescription)
                return
            }
            
            completionHandlerForPostUserLocation(true, nil)
            
        }
        task.resume()
        
    }
    
    //Mark: update user location
    
    func updateUserLocation(userIDUniqueKey : String , objectID : String , firstName : String , lastName : String , mapString : String , mediaURL : String , latitude : Double , longitude : Double , completionHandlerForUpdateUserLocation : @escaping (_ success : Bool , _ error : String?) -> Void ) {
        
        // Create the request
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectID)")!)
        request.httpMethod = "PUT"
        
        // Pass both Application & Rest API Keys
        request.addValue(studentsInfo.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(studentsInfo.restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(userIDUniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            
            guard error == nil else {
                print(error)
                
                print("Error found  UserSessionKey (func updateUserLocation) ")
                completionHandlerForUpdateUserLocation(false, error?.localizedDescription)
                return
            }
            
            completionHandlerForUpdateUserLocation(true, nil)
        }
        task.resume()
    }
    
    //Mark: delete user location
    
    func removeUserLocation(objectID : String , completionHandlerForRemoveUserLocation : @escaping (_ success : Bool? , _ error : String?) -> Void ) {
        
        let request = NSMutableURLRequest(url: URL(string: " https://parse.udacity.com/parse/classes/StudentLocation/\(objectID)")!)
        
        request.httpMethod = "DELETE"
        
        request.addValue(studentsInfo.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(studentsInfo.restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //Make a request
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response , error in
            
            //Guard error Nil check
            guard  error == nil else {
                completionHandlerForRemoveUserLocation(false, "Error found out in Remove User Location")
                return
            }
            
            completionHandlerForRemoveUserLocation(true, nil)
        }
        task.resume()
    }
    
}


