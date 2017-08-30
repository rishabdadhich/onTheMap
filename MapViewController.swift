//
//  MapViewController.swift
//  onTheMap
//
//  Created by Rishabh on 03/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate {
    
    @IBOutlet weak var mapview: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //Mark: get user clocation on map
        
        parsingData.sharedInstance().getUserLocation(userInfo.userKey){ (success,error) in
            
            if success! {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let latitude = userInfo.mapLatitude
                let longitude = userInfo.mapLongitude
                
                let total = latitude + longitude
                // check for != 0 and >0
                
                if total != 0 {
                    self.performUIUpdatesOnMain {
                        let coordinateLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let coordinateSpan = MKCoordinateSpanMake(10, 10)
                        let coordinateRegion = MKCoordinateRegion(center: coordinateLocation, span: coordinateSpan)
                        self.mapview.setRegion(coordinateRegion, animated: true)
                        
                    }
                }
            }
            else{
                print(error!)
                self.displayAlertMessage(message: error!)
            }
        }
        
        //Mark: get multiple students location on map
        
        parsingData.sharedInstance().getStudentsLocation(){ (success , error) in
            
            if success! {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                // remove old pins
                self.mapview.removeAnnotations(self.mapview.annotations)
                
                // reinitialize map with new refreshed pins
                
                self.reinitializePopulateMap()
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlertMessage(message: error!)
            }
            
        }
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        parsingData.sharedInstance().getStudentsLocation(){
            (success , error) in
            if success! {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.performUIUpdatesOnMain {
                    self.mapview.removeAnnotations(self.mapview.annotations)
                    self.reinitializePopulateMap()
                    
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlertMessage(message: error!)
            }
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        udacityClient.sharedInstance().deleteUserSession(){
            (success , error) in
            
            if success {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlertMessage(message: error!)
            }
        }
    }
    
    
    
    func reinitializePopulateMap(){
        var annotations = [MKPointAnnotation]()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        for data in studentDict.sharedInstance.studentsDict {
            
            let lat = CLLocationDegrees(data.latitude)
            let long = CLLocationDegrees(data.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // map annotation with coordinate, name an media URL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(data.firstName) \(data.lastName)"
            annotation.subtitle = data.mediaURL
            
            annotations.append(annotation)
        }
        // add annotation to map
        mapview.addAnnotations(annotations)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //Mark: for opening pin view of students
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapview.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation:annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }else{
            pinView?.annotation = annotation
        }
        return pinView
        
    }
    
    
    
    // open link on browser
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let mediaUrl = URL(string: displayAlert.sharedInstance().formatURL(url: ((view.annotation?.subtitle)!)!))
        
        UIApplication.shared.open(mediaUrl!, options: [:], completionHandler: nil)
    }
    
}
