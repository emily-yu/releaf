//
//  NewPostController.swift
//  releaf
//
//  Created by Emily on 3/25/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var replies2: [String] = ["First Prompt", "Second Prompt", "Third Prompt", "Fourth Prompt"]

class NewPostController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func post(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(currentIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in

            var replyIndex = String((((snapshot.value!) as AnyObject).count))
            self.ref.child("post").child(String(currentIndex)).child("reply").child(replyIndex).setValue([
                "likes": 0,
                "text": self.userText.text!,
                "user": FIRAuth.auth()!.currentUser!.uid,
                "uid": [
                    "0": "deafult"
                ]
            ])
            
//            // setting attributes for one post
//            self.ref.child("post/" + (String((((snapshot.value!) as AnyObject).count))) + "/leaves").setValue(0)
//        // things to set for new posts

//        self.ref.child("post/1/leaves").setValue(0)
//        self.ref.child("post/1/text").setValue(self.userText.text)
//        self.ref.child("post/1/user").setValue(FIRAuth.auth()!.currentUser!.uid)
//
//        self.ref.child("post/1/leaves").setValue(3)
//        self.ref.child("post/1/leaves").setValue(3)
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(replies2.count)
        print("sakefjalsdfjkladsf")
        return replies2.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:ReplyPromptTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ReplyPromptTableCell") as! ReplyPromptTableViewCell
        
        cell.promptText.text = String(replies2[indexPath.row])
   
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        switch (indexPath.row) {
        case 0:
            userText.text = "First Prompt"
        case 1:
            userText.text = "Second Prompt"
        case 2:
            userText.text = "Third Prompt"
        case 3:
            userText.text = "Fourth Prompt"
        default:
            print("asdf")
        }
        
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "postControllerSegue"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 0
                print("called")
            }
        }
    }
}
