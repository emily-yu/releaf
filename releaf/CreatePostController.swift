//
//  CreatePostController.swift
//  releaf
//
//  Created by Emily on 3/25/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CreatePostController: UIViewController {

    var ref:FIRDatabaseReference!
    @IBOutlet var body: UITextView!
    
    @IBOutlet var anonButton: UIButton!
    @IBAction func anon_isChecked(_ sender: Any) {
        if (anonButton.backgroundColor == UIColor.white) {
            anonButton.backgroundColor = UIColor.green
        }
        else {
            anonButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func postButton(_ sender: Any) {
        newPost()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
    }
    
    func newPost() {
        if self.body.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter a message.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            if (groupPathPost == nil) { // normal post to global community
                ref = FIRDatabase.database().reference()
                
                var anonStatus: Bool
                if (anonButton.backgroundColor == UIColor.white) {
                    anonStatus = false
                }
                else {
                    anonStatus = true
                }
                
                self.ref.child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let int = (snapshot.value) {
                        var same = (String((int as AnyObject).count)) as String!
                        self.ref.child("post").child(same!).setValue([
                            "reply": [
                                "0": [
                                    "likes": 0,
                                    "text": "reply text",
                                    "user": "default uid",
                                    "uid": [
                                        "0": "asdf"
                                    ],
                                ]
                            ],
                            "user": userID,
                            "text": self.body.text!,
                            "leaves": 0,
                            "hugs": [
                                "0": "sadjkl"
                            ],
                            "metoo": [
                                "0": "asdklfj2"
                            ],
                            "anonStatus" : anonStatus,
                            ] as NSDictionary)
                        
                        var baseValue = (((snapshot.value!) as AnyObject).count)
                        
                        // creating post under that person's account
                        self.ref.child("users").child(userID).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            var string = String((((snapshot.value!) as AnyObject).count)) // amount of posts there are + 1 to create new post
                            self.ref.child("users").child(userID).child("myPosts").child(string).setValue(baseValue)
                        }
                        
                        // add a point to eh persons account
                        self.incrementPoints()
                        
                        //navigate back to home screen
                        var ivc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                        ivc?.modalPresentationStyle = .custom
                        ivc?.modalTransitionStyle = .crossDissolve
                        self.present(ivc!, animated: true, completion: { _ in })
                    }
                })
            }
            else { // post to specific group
                ref = FIRDatabase.database().reference()
                self.ref.child("groups").child(String(groupPathPost)).child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let int = (snapshot.value) {
                        var same = (String((int as AnyObject).count)) as String!
                        self.ref.child("groups").child(String(groupPathPost)).child("post").child(same!).setValue([
                            "reply": [
                                "0": [
                                    "likes": 0,
                                    "text": "reply text",
                                    "user": "default uid",
                                    "uid": [
                                        "0": "asdf"
                                    ],
                                ]
                            ],
                            "user": userID,
                            "text": self.body.text!,
                            "leaves": 0,
                            "hugs": [
                                "0": "sadjkl"
                            ],
                            "metoo": [
                                "0": "asdklfj2"
                            ],
                            ] as NSDictionary)
                        
                        // add a point to eh persons account
                        self.incrementPoints()
                        
                        //navigate back to home screen
                        var ivc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                        ivc?.modalPresentationStyle = .custom
                        ivc?.modalTransitionStyle = .crossDissolve
                        self.present(ivc!, animated: true, completion: { _ in })
                    }
                })
            }
        }
    }
    
    func incrementPoints() {
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                var same = (int as! Int)+1;// add one reveal point
                self.ref.child("users").child(userID).child("revealPoints").setValue(same) // set new value
            }
        }
    }
}
