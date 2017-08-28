//
//  displayAlert.swift
//  onTheMap
//
//  Created by Rishabh on 01/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation
import UIKit

class displayAlert{
    
    func formatURL(url: String) -> String {
        var formattedURL = url
        if formattedURL.characters.first != "h"  && formattedURL.characters.first != "H"{
            formattedURL = "http://\(formattedURL)"
        }
        return String(formattedURL.characters.filter { !" ".characters.contains($0) })
    }
    

    class func sharedInstance() -> displayAlert {
        struct Singleton{
            static var sharedInstance = displayAlert()
        }
        return Singleton.sharedInstance
    }
}


extension UIViewController{
    
    func displayAlertMessage (message: String, completionHandler: ((UIAlertAction) -> Void)? = nil) {
        performUIUpdatesOnMain {
            
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completionHandler))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
