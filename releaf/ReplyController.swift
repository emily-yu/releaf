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


class NewPostController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userText: UITextView!
    @IBOutlet var anonButton: UIButton!
    @IBAction func anon_isChecked(_ sender: Any) {
        if (anonButton.backgroundColor == UIColor.white) {
            anonButton.backgroundColor = UIColor.green
        }
        else {
            anonButton.backgroundColor = UIColor.white
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view, typically from a nib.
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }
    
    @IBAction func post(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        var anonStatus: Bool
        if (anonButton.backgroundColor == UIColor.white) {
            anonStatus = false
        }
        else {
            anonStatus = true
        }
        ref.child("post").child(String(currentIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in

            let replyIndex = String(snapshot.childrenCount)
            self.ref.child("post").child(String(currentIndex)).child("reply").child(replyIndex).setValue([
                "likes": 0,
                "text": self.userText.text!,
                "user": FIRAuth.auth()!.currentUser!.uid,
                "uid": [
                    "0": "deafult"
                ],
                "anon" : anonStatus,
            ])
        }
        
        // TODO: CONVERT THIS INTO A GENERIC FUNCTION
        // Add to original poster's notifactions
        self.ref.child("post").child(String(currentIndex)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            let originalPoster = snapshot.value
            self.ref.child("users").child(originalPoster as! String).child("notification").observeSingleEvent(of: .value, with: { (snapshot) in
                if let int = (snapshot.value) {
                    let same = (String((int as AnyObject).count)) as String!
                    self.ref.child("users").child(originalPoster as! String).child("notification").child(same!).setValue([
                        "action" : "like",
                        "post"   : currentIndex,
                        "user"   : userID,
                    ] as NSDictionary)
                }
            })
        }

        appFunctions().incrementPoints();
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(replyPrompts.count)
        print("sakefjalsdfjkladsf")
        return replyPrompts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ReplyPromptTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ReplyPromptTableCell") as! ReplyPromptTableViewCell
        
        cell.promptText.text = String(replyPrompts[indexPath.row])
   
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        userText.text = replyPrompts[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appFunctions().navigateTabController(index: 0, sIdentifier: "postControllerSegue", segue: segue);
    }
}

class ReplyPromptTableViewCell: UITableViewCell {
    @IBOutlet var promptText: UILabel!
}
