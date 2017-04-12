//
//  GroupViewController.swift
//  releaf
//
//  Created by Emily on 3/28/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var restaurantNames = [String]() // lul groups

// TODO: join groups, create groups

class GroupViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var nameField: UILabel!
    var tempFirst = ""
    var tempLast = ""
    @IBOutlet var tableView: UITableView!
    @IBOutlet var impactPoints: UILabel!
    @IBOutlet var revealPoints: UILabel!
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        // set name
    self.ref.child("users").child(userID).child("firsasdfadsftName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.tempFirst = String(describing: snapshot.value!)
            print(snapshot.value!)
        })
        self.ref.child("users").child(userID).child("lastName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.tempLast = String(describing: snapshot.value!)
            print(snapshot.value!)
            self.nameField.text = self.tempFirst + " " + self.tempLast
        })
        
        // set impact points
        self.ref.child("users").child(userID).child("impactPoints").observeSingleEvent(of: .value, with: { (snapshot) in
            self.tempFirst = String(describing: snapshot.value!)
            print(snapshot.value!)
            self.impactPoints.text = "IMPACT POINTS: \(snapshot.value!)"
        })
        
        // set reveal points
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value!)
            self.revealPoints.text = "REVEAL POINTS: \(snapshot.value!)"
        })
        
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
//        print(groups.count)
        

    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:GroupTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
        //        cell.prompt.text = String(groups[indexPath.row])
        cell.groupText.text = String(restaurantNames[indexPath.row])
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
