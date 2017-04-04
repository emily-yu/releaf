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

// FINISHED
class CreatePostController: UIViewController {

    let userID = FIRAuth.auth()!.currentUser!.uid
    var ref:FIRDatabaseReference!
    
    @IBOutlet var header: UITextField!
    @IBOutlet var body: UITextView!
    @IBOutlet var segmentedView: UISegmentedControl!
    @IBOutlet var anonControl: UISegmentedControl!
    
    @IBAction func postButton(_ sender: Any) {
        newPost()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func newPost() {
        
        // if element is missing
        if self.header.text == "" || self.body.text == "" {

            let alertController = UIAlertController(title: "Error", message: "Please enter a header and body.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        else {
            ref = FIRDatabase.database().reference()
            ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                
                // setting attributes for one post
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/leaves").setValue(self.header.text!)
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/text").setValue(self.body.text!)
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/user").setValue(self.userID)
                // ADJUST THING TO READ REPLIES STARTING AT 1 SINCE ZERO IS EMPTY
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/reply/0/text").setValue("reply text")
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/reply/0/user").setValue(self.userID) // base response for init
                var baseValue = String(((snapshot.value!) as AnyObject).count)
                
                // creating post under that person's account
                self.ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                    var string = String((((snapshot.value!) as AnyObject).count) + 1) // amount of posts there are + 1 to create new post
                    self.ref.child(self.userID).child("myPosts").setValue([string:baseValue])
                }
                
            // anonymous control
            if (self.anonControl.selectedSegmentIndex == 0){
                print("fullanon")
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/status").setValue("fullanon")
            }
            else {
                print("partanon")
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/status").setValue("partanon")
            }
            
            //navigate back to home screen
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            self.present(vc!, animated: true, completion: nil)
        }

    
        }
    }
    
}
