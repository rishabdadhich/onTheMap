//
//  TableViewController.swift
//  onTheMap
//
//  Created by Rishabh on 04/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//
import Foundation
import UIKit

class TableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        parsingData.sharedInstance().getStudentsLocation(){ (success ,error) in
            
            if success!{
                
                // reload table data
                self.performUIUpdatesOnMain {
                    self.tableView.reloadData()
                    
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlertMessage(message: error!)
            }
            
    }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
}//end view will appear
    
    // no. of rows
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentDict.sharedInstance.studentsDict.count
    }
    
    //configure table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        let studentTable = studentDict.sharedInstance.studentsDict[indexPath.row]
        cell.textLabel?.text = studentTable.firstName + " " + studentTable.lastName
        cell.detailTextLabel?.text = studentTable.mapString.capitalized
        return cell
    }
    
    // tap on cell to open student link
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect the slected row to make the link selected
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // url in correct format
        if let url = URL(string: displayAlert.sharedInstance().formatURL(url: studentDict.sharedInstance.studentsDict[indexPath.row].mediaURL)){
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
    
    // swipe to delete
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // check row belongs to user and user can only delete its own informtion
        let rowStudent = studentDict.sharedInstance.studentsDict[indexPath.row]
        return rowStudent.uniqueKey == userInfo.userKey
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
        
        let rowStudent = studentDict.sharedInstance.studentsDict[indexPath.row]
        
        // remove row
            studentDict.sharedInstance.studentsDict.remove(at: indexPath.row)
            
        
        
        // remove user from parse data
        
            parsingData.sharedInstance().removeUserLocation(objectID:rowStudent.objectID){(success,error) in
                
                if success!{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    //reset user information locally
                    
                    userInfo.mapLatitude = 0.00
                    userInfo.mapLongitude = 0.00
                    userInfo.userMapString = ""
                    userInfo.userURLStatus = ""
                    userInfo.objectId = ""
                    
                }else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlertMessage(message: error!)
                    
                }
                
            }
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        udacityClient.sharedInstance().deleteUserSession(){(success,error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if success{
                self.performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlertMessage(message: error!)

            }
            
            }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func resetButton(_ sender: Any) {
        parsingData.sharedInstance().getStudentsLocation(){(success,error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if success!{
                self.performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlertMessage(message: error!)
            }
            }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
