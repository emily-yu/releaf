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

        // things to set for new posts
//        self.ref.child("post/1/leaves").setValue(3)
//        self.ref.child("post/1/text").setValue("ReplyText")
//        self.ref.child("post/1/user").setValue("Username")
        
        print()
//        self.ref.child("post/1/leaves").setValue(3)
//        self.ref.child("post/1/leaves").setValue(3)

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
//        cell.leaves.text = String(troll[indexPath.row])
//        
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
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            replies.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // action one
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            print("Edit tapped")
        })
        editAction.backgroundColor = UIColor.blue
        
        // action two
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            print("Delete tapped")
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [editAction, deleteAction]
    }

}
