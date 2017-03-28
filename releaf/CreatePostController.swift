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

    var ref: FIRDatabaseReference!
    
    @IBOutlet var header: UITextField!
    @IBOutlet var body: UITextView!
    @IBOutlet var segmentedView: UISegmentedControl!
    
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
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/leaves").setValue(self.header.text!)
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/text").setValue(self.body.text!)
                self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/user").setValue("Username")
                // ADD BLANK FOR REPLIES
            
            //Go to the HomeViewController if the login is sucessful
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            self.present(vc!, animated: true, completion: nil)
        }

    
        }
    }
    
}
