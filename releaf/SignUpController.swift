//
//  SignUpController.swift
//  releaf
//
//  Created by Emily on 3/18/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn

class SignUpController: UIViewController {
    
    var ref:FIRDatabaseReference!
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func createAccount(_ sender: Any) {
        self.ref = FIRDatabase.database().reference()
        if emailField.text! == "" || passwordField.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                
                if error == nil {
                    // set user details
                    self.ref.child("users").child((user?.uid)!).setValue([
                        "firsasdfadsftName": self.firstNameField.text!,
                        "lastName": self.lastNameField.text!,
                        "profilePic": "encoded picture", // encode profile pictures
                        "impactPoints": 0,
                        "revealPoints": 0,
                        "groups": [
                            "0": "Global Community"
                        ]
                    ])
                    print("asdfasdf")
                    print("You have successfully signed up")
                    
                    //login w/ new account
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    print((user?.uid)!)
                    
                    
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

