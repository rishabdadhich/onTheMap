//
//  loginViewController.swift
//  onTheMap
//
//  Created by Rishabh on 31/05/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit

class loginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        passwordText.text = ""
        usernameText.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!, options: [:], completionHandler: nil)
        
    }
    @IBAction func loginPressed(_ sender: Any) {
        setUIEnabled(enable: false)
        //Mark: for valid entry
        
        guard usernameText.text != nil && (usernameText.text?.contains("@"))! else {
            setUIEnabled(enable: true)
            displayAlertMessage(message: "Please enter a valid email")
            return
        }
        
        guard passwordText.text != nil else {
            setUIEnabled(enable: true)
            displayAlertMessage(message: "Please enter a password")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //Mark: Login process
        udacityClient.sharedInstance().getUserSessionKey(usernameText.text!, passwordText.text!) { userSessionKey , error in
            
            if let userSession = userSessionKey {
                udacityClient.sharedInstance().identifyUserWithSessionKey(userSessionKey: userSession){ success , error in
                    
                    if success! {
                        self.completeLogIn()
                    }else{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.displayAlertMessage(message: error!)
                    }
                    
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.setUIEnabled(enable: true)
                self.displayAlertMessage(message: error!)
            }
            
        }
    }
    
    func setUIEnabled(enable:Bool) {
        loginButton.isEnabled = enable
        
        performUIUpdatesOnMain{
            if enable{
                self.loginButton.setTitle("Sign In", for: .normal)
            }else{
                self.loginButton.setTitle("Signing In", for: .disabled)
            }
        }
    }
    
    func completeLogIn()   {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        performUIUpdatesOnMain {
            self.setUIEnabled(enable: true)
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "MapTabBarController") as! UITabBarController
            print("successfully loged in")
            self.present(controller, animated: true, completion: nil)
            
        }
    }
    // MARK: Hide keyboard when return key is pressed and perform submit action
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        loginButton.sendActions(for: .touchUpInside)
        print("return is pressed")
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        usernameText.resignFirstResponder()
        passwordText.resignFirstResponder()
    }
    
    ////////// keyboard part ////////
    
    func keyboardWillShow(_ notification:Notification) {
        if passwordText.isFirstResponder && view.frame.origin.y == 0.0 {
            
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if passwordText.isFirstResponder {
            
            view.frame.origin.y = 0
        }
    }
    
    
}
