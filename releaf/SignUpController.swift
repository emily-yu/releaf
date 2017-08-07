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

class SignUpController: UIViewController{
    
    var ref:FIRDatabaseReference!
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField! // changed to school
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func loginController(_ sender: Any) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var ivc = storyboard.instantiateViewController(withIdentifier: "login")
        ivc.modalPresentationStyle = .custom
        ivc.modalTransitionStyle = .crossDissolve
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
    }
    
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
                    userID  = FIRAuth.auth()!.currentUser!.uid
                    // set user details
                    self.ref.child("users").child((user?.uid)!).setValue([
                        "firsasdfadsftName": self.firstNameField.text!,
                        "school": self.lastNameField.text!,
                        "revealPoints": 0,
                        "groups": [
                            "0": "Global Community"
                        ],
                        "myPosts": [
                            "0": 0
                        ],
                        "favorites" : [
                            "0": 0,
                        ],
                        "base64string": "default"
                    ])
                    
                    // append, then transfer to array
                    self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        for index in 0...snapshot.childrenCount {
                            self.ref.child("users").child(userID).child("myPosts").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                                if var same:Int = (snapshot.value! as? Int) {
                                    myposts.append(same)
                                    self.ref.child("post").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                                        let int = snapshot.value!
                                        myPostsText.append(int as! String)
                                    })
                                }
                            })
                        }
                    }
                    
                    var storyboard = UIStoryboard(name: "Main", bundle: nil)
                    var ivc = storyboard.instantiateViewController(withIdentifier: "Home")
                    ivc.modalPresentationStyle = .custom
                    ivc.modalTransitionStyle = .crossDissolve
                    self.present(ivc, animated: true, completion: { _ in })

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
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toLogin") {
            if let tabVC = segue.destination as? UIViewController{
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
        appFunctions().navigateTabController(index: 0, sIdentifier: "postControllerSegue", segue: segue);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

