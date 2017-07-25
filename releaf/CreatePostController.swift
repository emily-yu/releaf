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

    var ref:FIRDatabaseReference!
    @IBOutlet var body: UITextView!
    
    @IBOutlet var destination: UITextView!
    
    @IBOutlet var anonButton: UIButton!
    @IBAction func anon_isChecked(_ sender: Any) {
        if (anonButton.backgroundColor == UIColor.white) {
            anonButton.backgroundColor = UIColor.green
        }
        else {
            anonButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func postButton(_ sender: Any) {
        newPost()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        if (postDestination.count == 0) {
            destination.text.append("You have no groups added. You must select at least one post destination")
        }
        else {
            for text in postDestination {
                if (text == postDestination[0]) {
                    destination.text = text
                }
                else {
                    destination.text.append(", \(text)")
                }
            }
        }
    }
    
    func newPost() {
        if self.body.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter a message.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            if (groupPathPost == nil) { // normal post to global community
                ref = FIRDatabase.database().reference()
                
                var anonStatus: Bool
                if (anonButton.backgroundColor == UIColor.white) {
                    anonStatus = false
                }
                else {
                    anonStatus = true
                }
                
                self.ref.child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let int = (snapshot.value) {
                        var same = (String((int as AnyObject).count)) as String!
                        self.ref.child("post").child(same!).setValue([
                            "reply": [
                                "0": [
                                    "likes": 0,
                                    "text": "reply text",
                                    "user": "default uid",
                                    "uid": [
                                        "0": "asdf"
                                    ],
                                ]
                            ],
                            "user": userID,
                            "text": self.body.text!,
                            "leaves": 0,
                            "hugs": [
                                "0": "sadjkl"
                            ],
                            "metoo": [
                                "0": "asdklfj2"
                            ],
                            "anonStatus" : anonStatus,
                            ] as NSDictionary)
                        
                        var baseValue = (((snapshot.value!) as AnyObject).count)
                        
                        // creating post under that person's account
                        self.ref.child("users").child(userID).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            var string = String((((snapshot.value!) as AnyObject).count)) // amount of posts there are + 1 to create new post
                            self.ref.child("users").child(userID).child("myPosts").child(string).setValue(baseValue)
                        }
                        
                        // add a point to eh persons account
                        self.incrementPoints()
                        
                        //navigate back to home screen
                        var ivc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                        ivc?.modalPresentationStyle = .custom
                        ivc?.modalTransitionStyle = .crossDissolve
                        self.present(ivc!, animated: true, completion: { _ in })
                    }
                })
            }
            else { // post to specific group
                ref = FIRDatabase.database().reference()
                self.ref.child("groups").child(String(groupPathPost)).child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let int = (snapshot.value) {
                        var same = (String((int as AnyObject).count)) as String!
                        self.ref.child("groups").child(String(groupPathPost)).child("post").child(same!).setValue([
                            "reply": [
                                "0": [
                                    "likes": 0,
                                    "text": "reply text",
                                    "user": "default uid",
                                    "uid": [
                                        "0": "asdf"
                                    ],
                                ]
                            ],
                            "user": userID,
                            "text": self.body.text!,
                            "leaves": 0,
                            "hugs": [
                                "0": "sadjkl"
                            ],
                            "metoo": [
                                "0": "asdklfj2"
                            ],
                            ] as NSDictionary)
                        
                        // add a point to eh persons account
                        self.incrementPoints()
                        
                        //navigate back to home screen
                        var ivc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                        ivc?.modalPresentationStyle = .custom
                        ivc?.modalTransitionStyle = .crossDissolve
                        self.present(ivc!, animated: true, completion: { _ in })
                    }
                })
            }
        }
    }
    
    func incrementPoints() {
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                var same = (int as! Int)+1;// add one reveal point
                self.ref.child("users").child(userID).child("revealPoints").setValue(same) // set new value
            }
        }
    }
}

class SelectGroup: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var ref:FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ref = FIRDatabase.database().reference()
        checkIfFirstLoad() // set up tableView data
        
        // set up tableviewcells
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
//        let cells = self.tableView.visibleCells as! Array<GroupCell>
//        print("SAEMAMSEMAMEMSAME\(cells)")
//        for cell in cells {
//            // look at data
//            print(cell.groupName.text)
//            if postDestination.contains(String(describing: cell.groupName.text)) {
//                print("yes")
//                cell.cellState.image = #imageLiteral(resourceName: "check")
//            }
//        }
    }
    
    @IBAction func addGroups(_ sender: Any) {
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allgroups.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:GroupCell = self.tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
        cell.groupName.text = String(allgroups[indexPath.row])
        if postDestination.contains(String(allgroups[indexPath.row])) {
            print("yes")
            cell.cellState.image = #imageLiteral(resourceName: "check")
        }
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var groupJoin = allgroups[indexPath.row]
        let cell = self.tableView.cellForRow(at: indexPath) as! GroupCell
        if (cell.cellState.image == #imageLiteral(resourceName: "check")) {
            cell.cellState.image = nil
            postDestination = postDestination.filter {$0 != groupJoin}
        }
        else {
            cell.cellState.image = #imageLiteral(resourceName: "check")
            postDestination.append(groupJoin)
        }
        print(postDestination)
        tableView.deselectRow(at: indexPath, animated: true)
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
            let cells = self.tableView.visibleCells as! Array<GroupCell>
            print("SAEMAMSEMAMEMSAME\(cells)")
            for cell in cells {
                // look at data
                print(cell.groupName.text)
                if postDestination.contains(String(describing: cell.groupName.text)) {
                    print("yes")
                    cell.cellState.image = #imageLiteral(resourceName: "check")
                }
            }
        }
        else {
            allgroups.removeAll()
            groupDescription2.removeAll()
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
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
        
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newPost"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 1
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
    }
}

class GroupCell: UITableViewCell {
    @IBOutlet var groupName: UILabel!
    @IBOutlet var cellState: UIImageView!
}
