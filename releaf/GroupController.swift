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

var allgroups: [String] = [] // list of groups to join
var groupDescription2: [String] = [] // description of groups in JoinController
var firstLoad_join = false // used for checking if it was the first time loading

class JoinController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        checkIfFirstLoad() // set up tableView data
        
        // set up tableviewcells
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func checkIfFirstLoad() {
        if (firstLoad_join == false) {
            firstLoad_join = true
            print("FIRST LOAD")
            self.ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                for index in 0...(((snapshot.value!) as AnyObject).count - 1) {
                    self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                        if var same:String = (snapshot.value! as? String) {
                            groupDescription2.append(same)
                        }
                    })
                    self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                        if var same:String = (snapshot.value! as? String) {
                            allgroups.append(same)
                        }
                    })
                }
            }
        }
        else {
            print("NOT FIRST LOAD")
            allgroups.removeAll()
            groupDescription2.removeAll()
            self.ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                    self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                        if var same:String = (snapshot.value! as? String) {
                            groupDescription2.append(same)
                        }
                    })
                    self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                        if var same:String = (snapshot.value! as? String) {
                            allgroups.append(same)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDescription2.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:JoinTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "JoinTableViewCell") as! JoinTableViewCell
        cell.groupName.text = String(allgroups[indexPath.row])
        cell.groupDescription.text = String(groupDescription2[indexPath.row])
//
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // change imageview to a checkmark
        // if imageview.image = the plus image then add it, if not then have popup that says you have already joined this group
        var groupJoin = allgroups[indexPath.row]
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            // creating post under that person's account
            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                var string = String((((snapshot.value!) as AnyObject).count)) // amount of posts there are + 1 to create new post
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").child(string).setValue(groupJoin)
            }
            
            restaurantNames.removeAll() // so it can reload
            
            //navigate back
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            if let tabvc = vc as? UITabBarController {
                tabvc.selectedIndex = 3
                tabvc.modalPresentationStyle = .custom
                tabvc.modalTransitionStyle = .crossDissolve
                self.present(tabvc, animated: true, completion: nil)
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
    @IBAction func createGroup(_ sender: Any) {
        if (self.groupDescription.text != "" || self.groupName.text != "") {
            if ((self.groupDescription.text?.characters.count)! < 30) {
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
                            
                            // issue here with modifying actual data
                            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").setValue([string:baseValue])
                        }
                        
                        allgroups.removeAll()
                        groupDescription2.removeAll()
                        self.ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                                self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if var same:String = (snapshot.value! as? String) {
                                        groupDescription2.append(same)
                                    }
                                })
                                self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if var same:String = (snapshot.value! as? String) {
                                        allgroups.append(same)
                                    }
                                })
                            }
                        }
                    }
                })
            }
            else {
                let alertController = UIAlertController(title: "Error", message: "The max character limit for group descriptions is 30.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "Please fill out all the required fields.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "profileSegue" || segue.identifier == "createGroupSegue"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 3
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ref = FIRDatabase.database().reference()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
