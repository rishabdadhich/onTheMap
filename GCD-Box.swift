//
//  GCD-Box.swift
//  onTheMap
//
//  Created by Rishabh on 01/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func performUIUpdatesOnMain(updates  : @escaping() -> Void) {
        DispatchQueue.main.async() {
            updates()
        }
        
    }
    
}
