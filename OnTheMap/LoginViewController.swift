//
//  ViewController.swift
//  OnTheMap
//
//  Created by James Tench on 8/29/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var facebookIconLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginWithFacebookButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorIconLabel: UILabel! // graphical representation of error
    
    let emailTextFieldDelegate = EmailTextFieldDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = emailTextFieldDelegate
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        errorIconLabel.font = UIFont(name: "icomoon", size: 20.0)
        errorIconLabel.textColor = UIColor.redColor()
        errorIconLabel.text = ""
        
        facebookIconLabel.font = UIFont(name: "icomoon", size: 18.0)
        facebookIconLabel.textColor = UIColor.whiteColor()
        facebookIconLabel.text = Icomoon.Facebook2.rawValue
        errorLabel.text = ""
    }
    
    // prevent double tapping which can cause multiple ui alerts to be fired
    func enableLoginButtons() {
        loginButton.enabled = true
        loginWithFacebookButton.enabled = true;
    }
    
    func disableLoginButtons() {
        loginButton.enabled = false
        loginWithFacebookButton.enabled = false
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            if let udacityUser = UdacityClient.sharedInstance().udacityStudent {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabController") as! UITabBarController
                self.presentViewController(controller, animated: true, completion: nil)
            } else {
                ApiHelper.displayErrorAlert(self, title: "Login Error", message: "No Udacity Student data")
            }

        }
    }
    
    func setErrorFields(error: String) {
        if error.rangeOfString("Account") != nil {
            self.errorIconLabel.text = Icomoon.Lock.rawValue
            self.errorLabel.text = "Incorrect login credentials - try again"
        } else if error.rangeOfString("Internet") != nil {
            self.errorIconLabel.text = Icomoon.Connection.rawValue
            self.errorLabel.text = "Please connect to the Internet"
        } else {
            self.errorIconLabel.text = Icomoon.Cross.rawValue
            self.errorLabel.text = "Unable to connect at thsi time"
        }
    }
    
    @IBAction func signUpTouchUp() {
        let app = UIApplication.sharedApplication()
        let udacityLoginURL = "https://www.udacity.com/account/auth#!/signup"
        app.openURL(NSURL(string: udacityLoginURL)!)
    }

    @IBAction func udacityLogin(sender: AnyObject) {
        if emailTextField.text.isEmpty {
            errorLabel.text = "Username Empty."
        } else if passwordTextField.text.isEmpty {
            errorLabel.text = "Password Empty."
        } else {
            // prevent double clicking / tapping
            disableLoginButtons()
            let userId = emailTextField.text
            let password = passwordTextField.text
            let credentials = [ "udacity" : [
                UdacityClient.JSONBodyKeys.UserName : userId,
                UdacityClient.JSONBodyKeys.Password : password
                ]
            ]
            
            UdacityClient.sharedInstance().authenticateWithCredentials(credentials) { success, errorString in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.completeLogin()
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        // for graphical representation of error
                        if let error = errorString {
                            self.setErrorFields(error)
                        }
                        ApiHelper.displayErrorAlert(self, title: "Login Error", message: errorString!)
                    }
                }
                // enable again for case of needing to try to login again
                self.enableLoginButtons()
            }
        }
    }
    
    @IBAction func facebookLogin(sender: AnyObject) {
        var login: FBSDKLoginManager = FBSDKLoginManager()
        let options = ["public_profile"]
        disableLoginButtons()
        // test if a token is cached to prevent unnecessary app switching
        if let currentToken = FBSDKAccessToken.currentAccessToken() {
            let credentials = [ "facebook_mobile" : [
                UdacityClient.JSONBodyKeys.Access : currentToken.tokenString
                ]
            ]
            UdacityClient.sharedInstance().authenticateWithCredentials(credentials) { success, errorString in
                if success {
                    UdacityClient.sharedInstance().facebookLogin = true
                    dispatch_async(dispatch_get_main_queue()) {
                        self.completeLogin()
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        // for graphical representation of error
                        if let error = errorString {
                            self.setErrorFields(error)
                        }
                        ApiHelper.displayErrorAlert(self, title: "Login Error", message: errorString!)
                    }
                }
                self.enableLoginButtons()
            }
        } else {
            login.logInWithReadPermissions(options) { result, error in
                if let error = error {
                    ApiHelper.displayErrorAlert(self, title: "Facebook Login - Error", message: "Error Logging in with Facebook")
                    self.enableLoginButtons()
                } else if result.isCancelled {
                    // if the user canceled out of the facebook authentication
                    ApiHelper.displayErrorAlert(self, title: "Facebook Login - Canceled", message: "Please allow access with Facebook, or login with Udacity")
                    self.enableLoginButtons()
                } else {
                    let credentials = [ "facebook_mobile" : [
                        UdacityClient.JSONBodyKeys.Access : FBSDKAccessToken.currentAccessToken().tokenString
                        ]
                    ]
                    
                    UdacityClient.sharedInstance().authenticateWithCredentials(credentials) { success, errorString in
                        if success {
                            UdacityClient.sharedInstance().facebookLogin = true
                            dispatch_async(dispatch_get_main_queue()) {
                                self.completeLogin()
                            }
                            
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                // for graphical representation of error
                                if let error = errorString {
                                    self.setErrorFields(error)
                                }
                                ApiHelper.displayErrorAlert(self, title: "Login Error", message: errorString!)
                            }
                        }
                        self.enableLoginButtons()
                    }
                }
            }
        }
    }
}

