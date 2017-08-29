//
//  udacityClient.swift
//  onTheMap
//
//  Created by Rishabh on 31/05/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation

class udacityClient {
    
    class func sharedInstance() -> udacityClient {
        struct Singleton{
            static var sharedInstance = udacityClient()
        }
        return Singleton.sharedInstance
    
    }
    
    //Mark : get user session key
    
    func getUserSessionKey(_ username: String,_ password:String,completionHandlerForUserSessionKey: @escaping(_ sessionKey:String? ,_ error:String?) -> Void){
        
        let request = NSMutableURLRequest(url:URL(string:"https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {
            data ,response ,error in
            
            func displayError(_ error:String){
                print(error)
                completionHandlerForUserSessionKey(nil, error)
            }
            
            guard error == nil else{
                displayError("credentials are incorrect")
               return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,statusCode >= 200 && statusCode <= 299 else{
                displayError("no internet connection")
                return
            }
            
            guard let data = data else{
                displayError("error found in data")
                return
            }
            let userData = data.subdata(in : Range(5..<data.count))
            
            let parsedData : AnyObject
            do {
                parsedData = try JSONSerialization.jsonObject(with: userData, options: .allowFragments) as! NSDictionary
            }catch{
                displayError("error in parsing data in jsonserialization")
                return
            }
            
            if let account = parsedData["account"] as? [String:AnyObject]{
                let userSessionKey = account["key"] as? String
                userInfo.userKey = userSessionKey!
                
                completionHandlerForUserSessionKey(userSessionKey, nil)
            }
            else{
                displayError("invalid username or password")
            }
            
            
        }
        task.resume()
    }
    
    //Mark: identify user session key and retrive name
    
    func identifyUserWithSessionKey(userSessionKey:String,completionHandlerToIdentifyUserWithKey:@escaping(_ success:Bool? , _ error:String?)-> Void)  {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userSessionKey)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            data,response,error in
            
            func displayError(_ error :String){
                print(error)
                completionHandlerToIdentifyUserWithKey(false, error)
            }
            guard error == nil else {
                displayError("error found in error guard")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                displayError("error found in data")
                return
            }
             let userData = data.subdata(in: Range(5..<data.count))
            
            let parsedData : AnyObject
            do {
                parsedData = try JSONSerialization.jsonObject(with: userData, options: .allowFragments) as! NSDictionary
            }catch{
                displayError("error in parsing data in jsonserialization")
                return
            }
            let user = parsedData["user"] as! [String:AnyObject]
            let firstName = user["first_name"] as! String
            let lastName = user["last_name"] as! String
            
            userInfo.firstName = firstName
            userInfo.lastName = lastName
            
            completionHandlerToIdentifyUserWithKey(true, nil)
        }
        task.resume()
    }
    
    //Mark: delete user session 
    
    func deleteUserSession ( completionHandlerDeleteUserSession : @escaping ( _ success : Bool , _ error : String?) -> Void ) {
        
        
       
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            
           
            guard error == nil else {
                print(error)
                completionHandlerDeleteUserSession(false, "We couldn't Log you out")
                return
            }
            
            completionHandlerDeleteUserSession(true, nil)
            }
        task.resume()
    }

}
