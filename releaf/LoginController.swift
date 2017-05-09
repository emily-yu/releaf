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
    var ref: FIRDatabaseReference!
    
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
                    
                    userID  = FIRAuth.auth()!.currentUser!.uid
                    // set groups array
                    self.ref = FIRDatabase.database().reference()
                    
                    // append all the posts to myposts, then transfer to array
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        // get how many posts you have
                        for index in 0...(((snapshot.value!) as AnyObject).count) { // NULL WHEN NO POSTS - NULL ON
                            
                            self.ref.child("users").child(userID).child("myPosts").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                                if var same:Int = (snapshot.value! as? Int) {
                                    myposts.append(same)
                                    // acceses right posts and puts indexs in array
                                    // use array posts to same
//                                    for index2 in myposts {
                                        self.ref.child("post").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                                            let int = snapshot.value!
                                            myPostsText.append(int as! String)
                                        })
//                                    }
                                }
                            })
                        }
                    }

                    
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSignUp"){
            if let tabVC = segue.destination as? UIViewController{
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
