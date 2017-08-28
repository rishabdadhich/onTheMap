//
//  loginViewController.swift
//  onTheMap
//
//  Created by Rishabh on 31/05/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
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
        passwordText.text = ""
        usernameText.text = ""
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
        loginButton.sendActions(for: .touchUpInside)
        return false
    }


}
