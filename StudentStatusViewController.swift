//
//  StudentStatusViewController.swift
//  onTheMap
//
//  Created by Rishabh on 05/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit
import MapKit

class StudentStatusViewController: UIViewController,UITextFieldDelegate,MKMapViewDelegate {
    // UI view enums
    enum UIstate {
        case MapView
        case StatusURL
    }
    // Default ui
    var configuredUIState = "MapView"
    
    var pinPlacemark:CLPlacemark? = nil
    
    
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var postStatusLink: UITextField!
    
    @IBOutlet weak var studyingFrom: UILabel!
    
    @IBOutlet weak var searchLocationTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    // configure UI on input given
    func configureUI(state:UIstate) {
        if state == .MapView{
            self.configuredUIState = "MapView"
            mapView.isHidden = true
            findOnMapButton.isEnabled = true
            searchLocationTextField.isEnabled = true
            postStatusLink.isHidden = true
            findOnMapButton.setTitle("Find On The Map", for: UIControlState.normal)
            studyingFrom.isEnabled = true
            cancelButton.setTitleColor(UIColor.red, for: .normal)
            
        }
        if state == .StatusURL{
            self.configuredUIState = "StatusURL"
            mapView.isHidden = false
            findOnMapButton.isEnabled = true
            searchLocationTextField.isEnabled = false
            postStatusLink.isHidden = false
            findOnMapButton.setTitle("Update Status", for: UIControlState.normal)
            studyingFrom.isHidden = false
            cancelButton.setTitleColor(UIColor.green, for: .normal)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        performUIUpdatesOnMain {
            // add https prefix to url
            if self.postStatusLink.tag == 1 {
                self.postStatusLink.text = "https://"
            }
            self.configureUI(state: .MapView)
        }
    }
    
    
    
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findOnMapButtonPressed(_ sender: Any) {
        
        if configuredUIState == "MapView"{
            
            guard (searchLocationTextField.text?.isEmpty) != nil else {
                displayAlertMessage(message: "Please enter location")
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            performUIUpdatesOnMain {
                
                // geolocator object
                
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(self.searchLocationTextField.text!, completionHandler: {(results , error) in
                    
                    guard error == nil else{
                        self.displayAlertMessage(message: "sorry we found error while searching for string in geolocation map kit")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                    
                    guard results?.isEmpty == false else{
                        self.displayAlertMessage(message: "sorry we found error while searching for string in geolocation map kit")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                    self.pinPlacemark = results![0]
                    self.configureUI(state: .StatusURL)
                    self.mapView.showAnnotations([MKPlacemark(placemark: self.pinPlacemark!)], animated: true)
                    
                    //check user earlier status entries from userInfo.swift
                    if userInfo.userURLStatus.isEmpty == false{
                        self.postStatusLink.text = userInfo.userURLStatus
                        self.findOnMapButton.setTitle("Update Information", for: UIControlState.normal)
                    }
                }) //closure end
            }// perform ui update end
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
            
        else if configuredUIState == "StatusURL"{
            
            guard postStatusLink.text?.isEmpty != nil else {
                displayAlertMessage(message: "please enter some status url")
                return
            }
            
            // check whether user updating first time status or not ?
            
            if userInfo.objectId.isEmpty{
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                parsingData.sharedInstance().postUserLocation(userIDUniqueKey: userInfo.userKey, firstName: userInfo.firstName, lastName: userInfo.lastName, mapString: self.searchLocationTextField.text!, mediaURL: self.postStatusLink.text!, latitude: self.pinPlacemark!.location!.coordinate.latitude, longitude: self.pinPlacemark!.location!.coordinate.longitude){(success,error) in
                    
                    if success!{
                        self.performUIUpdatesOnMain {
                            //set user location coordinate to centre the map on when view controller is dismissed
                            userInfo.mapLatitude = self.pinPlacemark!.location!.coordinate.latitude
                            userInfo.mapLongitude = self.pinPlacemark!.location!.coordinate.longitude
                            userInfo.userMapString = self.searchLocationTextField.text!
                            userInfo.userURLStatus = self.postStatusLink.text!
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                    }else{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.displayAlertMessage(message: error!)
                        
                    }
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                parsingData.sharedInstance().updateUserLocation(userIDUniqueKey: userInfo.userKey, objectID: userInfo.objectId, firstName: userInfo.firstName, lastName: userInfo.lastName, mapString: self.searchLocationTextField.text!, mediaURL: self.postStatusLink.text!, latitude: self.pinPlacemark!.location!.coordinate.latitude, longitude: self.pinPlacemark!.location!.coordinate.longitude){(success,error) in
                    
                    if success{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                        
                        self.performUIUpdatesOnMain {
                            // set users location coordinate to center the map on when view controller is dismissed
                            
                            userInfo.mapLatitude = self.pinPlacemark!.location!.coordinate.latitude
                            userInfo.mapLongitude = self.pinPlacemark!.location!.coordinate.longitude
                            userInfo.userMapString = self.searchLocationTextField.text!
                            userInfo.userURLStatus = self.postStatusLink.text!
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    }else{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.displayAlertMessage(message: error!)
                        
                    }
                    
                }//update user location completed
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
        }// status url configured ui end
    }// find on map button end
    
    //Mark: hide keybord when return key is pressed and perform submit action on findOnMapButton
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        findOnMapButton.sendActions(for: .touchUpInside)
        return false
    }
    //Mark: add prefix https
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            textField.text = "https://"
        }
    }
}
