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
        if self.header.text == "" || self.body.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter a header and body.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            ref = FIRDatabase.database().reference()
            self.ref.child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                
                // anonymous control
                var anonStatus: String!
                if (self.anonControl.selectedSegmentIndex == 0){
                    print("fullanon")
                    self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/status").setValue("fullanon")
                    anonStatus = "fullanon"
                }
                else {
                    print("partanon")
                    self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/status").setValue("partanon")
                    anonStatus = "partanon"
                }
                
                if let int = (snapshot.value) {
                    var same = (String((int as AnyObject).count)) as String!
                    print("then goes in here?")
                    self.ref.child("post").child(same!).setValue([
                        "reply": [
                            "0": [
                                "likes": 0,
                                "text": "reply text",
                                "user": "default uid"
                            ]
                        ],
                        "user": self.userID,
                        "text": self.body.text!,
                        "leaves": 0,
                        "hugs": [
                            "0": "sadjkl"
                        ],
                        "metoo": [
                            "0": "asdklfj2"
                        ],
                        "status": anonStatus,
                        ] as NSDictionary)
                    
                    var baseValue = String(((snapshot.value!) as AnyObject).count)
                    
                    // creating post under that person's account
                    self.ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        var string = String((((snapshot.value!) as AnyObject).count) + 1) // amount of posts there are + 1 to create new post
                        self.ref.child(self.userID).child("myPosts").setValue([string:baseValue])
                    }
                    
                    //navigate back to home screen
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                }
            })
        }
    }
}
