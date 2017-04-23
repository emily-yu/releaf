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

// prompts
var replies2: [String] = ["Look at the progress you've made.",
                          "What is within your control?",
                          "Would it still matter 5 years later?",
                          "Is your problem actionable?",
                          "Write your personal mission statement.",
                          "What is the smallest step you can take?",
                          "Create a routine to prevent it from happening again.",
                          "Write down when and where you will be solving this problem.",
                          "Create a prototype to test your assumptions.",
                          "Do something in the next hour to answer a question you have.",
                          "Express your emotions to others.",
                          "Who can you collaborate on this?",
                          "Talk to a mentor.",
                          "Name 5 people you admire.",
                          "Build a supportive community.",
                          "Explore something new.",
                          "Take 5 minutes to do something you find interesting.",
                          "How can you approach this differently?",
                          "Have a beginner's mindset!",
                          "What are new opportunities?",
                          "What are you grateful for now?",
                          "Take 3 deep breaths.",
                          "Look at what is going on with kindness.",
                          "What do you value in this experience?",
                          "What have you learned in this experience?"]

class NewPostController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userText: UITextView!
    
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
        }
        
        // add a point to user points
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                var same = (int as! Int)+1;// add one reveal point
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("revealPoints").setValue(same) // set new value
            }
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
        userText.text = replies2[indexPath.row]
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "postControllerSegue"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 0
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
    }
}

class ReplyPromptTableViewCell: UITableViewCell {
    @IBOutlet var promptText: UILabel!
}
