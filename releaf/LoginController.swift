//
//  SecondViewController.swift
//  releaf
//
//  Created by Emily on 3/11/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginController: UIViewController, GIDSignInUIDelegate {

    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBAction func createAccount(_ sender: Any) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var ivc = storyboard.instantiateViewController(withIdentifier: "signup")
        ivc.modalPresentationStyle = .custom
        ivc.modalTransitionStyle = .crossDissolve
        self.present(ivc, animated: true, completion: { _ in })
    }
    @IBAction func loginButton(_ sender: Any) {
        if self.usernameField.text == "" || self.passwordField.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.usernameField.text!, password: self.passwordField.text!) { (user, error) in
                
                if error == nil {
                    var storyboard = UIStoryboard(name: "Main", bundle: nil)
                    var ivc = storyboard.instantiateViewController(withIdentifier: "Home")
                    ivc.modalPresentationStyle = .custom
                    ivc.modalTransitionStyle = .crossDissolve
                    self.present(ivc, animated: true, completion: { _ in })
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
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
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
