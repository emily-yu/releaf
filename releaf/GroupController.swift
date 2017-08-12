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

class JoinController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        loadData() // set up tableView data
        
        // set up tableviewcells
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func loadData() {
        
        // Retrieve list of groups
        self.ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            // Clearing data from previous group array
            allgroups.removeAll()
            groupDescription2.removeAll()
        
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same:String = (snapshot.value! as? String) {
                        groupDescription2.append(same)
                    }
                });
                self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same:String = (snapshot.value! as? String) {
                        allgroups.append(same)
                        self.tableView.reloadData()
                    }
                });
            }
        }
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupDescription2.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:JoinTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "JoinTableViewCell") as! JoinTableViewCell
        cell.groupName.text = String(allgroups[indexPath.row])
        cell.groupDescription.text = String(groupDescription2[indexPath.row])
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupJoin = allgroups[indexPath.row]
        
        if restaurantNames.contains(groupJoin) {
            let alertController = UIAlertController(title: "Error", message: "You've already joined this group.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        else {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                
                // creating post under that person's account
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                    let string = String(snapshot.childrenCount) // amount of posts there are + 1 to create new post
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
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appFunctions().navigateTabController(index: 3, sIdentifier: "profileSegue", segue: segue);
        appFunctions().navigateTabController(index: 3, sIdentifier: "createGroupSegue", segue: segue);
        
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
                        let same = (String((int as AnyObject).count)) as String!
                        self.ref.child("groups").child(same!).setValue([
                            "name": self.groupName.text!,
                            "description": self.groupDescription.text!,
                            "post": [
                                "0": "init",
                            ]
                        ] as NSDictionary)
                        
                        let baseValue = self.groupName.text!
                        restaurantNames.append(baseValue)
                        print("NEW ONE")
                        print(restaurantNames)
                        
                        
                        // add group under that person's account
                        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            let string = String(snapshot.childrenCount) // amount of posts there are + 1 to create new post
                            
                            // issue here with modifying actual data
                            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").child(string).setValue(baseValue)
                        }
                        
                        
                        self.ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            allgroups.removeAll()
                            groupDescription2.removeAll()
                            for index in 0...(snapshot.childrenCount - 1) { // NULL WHEN NO POSTS - NULL ON
                                self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let same:String = (snapshot.value! as? String) {
                                        groupDescription2.append(same)
                                    }
                                })
                                self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let same:String = (snapshot.value! as? String) {
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
        appFunctions().navigateTabController(index: 3, sIdentifier: "profileSegue", segue: segue);
        appFunctions().navigateTabController(index: 3, sIdentifier: "createGroupSegue", segue: segue);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ref = FIRDatabase.database().reference()
        
//        groupDescription.backgroundColor = UIColor(red: 67, green: 176, blue: 103, alpha: 1).withAlphaComponent(0.6)
//        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
