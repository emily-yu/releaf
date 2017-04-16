//
//  GroupController.swift
//  releaf
//
//  Created by Emily on 4/11/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var allgroups: [String] = []
var groupDescription: [String] = []

class JoinController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDescription.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:JoinTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "JoinTableViewCell") as! JoinTableViewCell
        cell.groupName.text = String(allgroups[indexPath.row])
        cell.groupDescription.text = String(groupDescription[indexPath.row])
//
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // change imageview to a checkmark
        // if imageview.image = the plus image then add it, if not then have popup that says you have already joined this group
        var groupJoin = allgroups[indexPath.row]
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            var string = String((((snapshot.value!) as AnyObject).count))
            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").child(string).setValue(groupJoin)
            
            //navigate back to home screen
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            
            self.present(vc!, animated: true, completion: nil)
        }
        
    }
// switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "profileSegue"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 3
                        print("called")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class JoinTableViewCell: UITableViewCell {

    @IBOutlet var groupName: UILabel!
    @IBOutlet var groupDescription: UILabel!
    
}

class CreateGroupController: UIViewController {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var groupName: UITextField!
    @IBOutlet var groupDescription: UITextView!
    @IBAction func createGroup(_ sender: Any) { // add check if gtorupname or desciprtion is dempty
        self.ref.child("groups").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let int = (snapshot.value) {
                var same = (String((int as AnyObject).count)) as String!
                self.ref.child("groups").child(same!).setValue([
                    "name": self.groupName.text!,
                    "description": self.groupDescription.text!,
                ] as NSDictionary)
                
                var baseValue = self.groupName.text!
                
                // add group under that person's account
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                    var string = String((((snapshot.value!) as AnyObject).count) + 1) // amount of posts there are + 1 to create new post
                    self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").setValue([string:baseValue])
                }
                
                //navigate back to home screen
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                self.present(vc!, animated: true, completion: nil)
            }
        })
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "profileSegue"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 3
                print("called")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}