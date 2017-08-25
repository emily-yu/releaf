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
            anonButton.backgroundColor = UIColor.green;
        }
        else {
            anonButton.backgroundColor = UIColor.white;
        }
    }
    
    @IBAction func postButton(_ sender: Any) {
        if self.body.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter a message.", preferredStyle: .alert);
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
            alertController.addAction(defaultAction);
            
            self.present(alertController, animated: true, completion: nil);
        }
        else {
            
            var anonStatusArray = [Bool]();
            var cancerCount = [Int]();
            if (groupPathPost == nil) { // normal post to global community + multiple groups from normal selector
                ref = FIRDatabase.database().reference();
                
                var anonStatus: Bool
                if (anonButton.backgroundColor == UIColor.white) {
                    anonStatus = false;
                    anonStatusArray.append(anonStatus);
                }
                else {
                    anonStatus = true;
                    anonStatusArray.append(anonStatus);
                }
                
                var keyarray = [String]();
                for group in postDestination {
                    self.ref.child("groups").queryOrdered(byChild: "name").queryEqual(toValue: group).observe(.value, with: { snapshot in
                        if (snapshot.value is NSNull) {
                            print("Item was not found")
                        }
                        else {
                            for child in snapshot.children {
                                let key = (child as AnyObject).key as String;
                                keyarray.append(key)
                                if (keyarray.count == postDestination.count) {
                                    for key in keyarray {
                                        self.ref.child("groups").child(key).child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                                            if let int = (snapshot.value) {
                                                cancerCount.append((Int((int as AnyObject).count)) as Int!);
                                                if (cancerCount.count == postDestination.count) {
                                                    let (first, last, interval) = (0, cancerCount.count, 1)
                                                    var n = 0;
                                                    for _ in stride(from: first, to: last, by: interval) {
                                                        n += 1;
                                                        self.ref.child("groups").child(keyarray[n-1]).child("post").child(String(describing: cancerCount[n-1])).setValue([
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
                                                        ] as NSDictionary);
                                                    }
                                                    for index in stride(from: (cancerCount.count-1), to: 0, by: 1){
                                                        self.ref.child("groups").child(keyarray[index]).child("post").child(String(describing: cancerCount[index])).setValue([
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
                                                        ] as NSDictionary);
                                                    }
                                                }
                                            }
                                        });
                                    }
                                }
                            }
                        }
                    });
                }
                
                self.ref.child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let int = (snapshot.value) {
                        let same = (String((int as AnyObject).count)) as String!
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
                            ] as NSDictionary);
                        
                        appFunctions().incrementPoints()

                        let ivc = self.storyboard?.instantiateViewController(withIdentifier: "Home");
                        ivc?.modalPresentationStyle = .custom;
                        ivc?.modalTransitionStyle = .crossDissolve;
                        self.present(ivc!, animated: true, completion: { _ in });
                    }
                });
            }
            else { // post to specific group
                ref = FIRDatabase.database().reference()
                self.ref.child("groups").child(String(groupPathPost)).child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let int = (snapshot.value) {
                        let same = (String((int as AnyObject).count)) as String!
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
                        ] as NSDictionary);
                        
                        // add a point to eh persons account
                        appFunctions().incrementPoints();
                        
                        //navigate back to home screen
                        let ivc = self.storyboard?.instantiateViewController(withIdentifier: "Home");
                        ivc?.modalPresentationStyle = .custom;
                        ivc?.modalTransitionStyle = .crossDissolve;
                        self.present(ivc!, animated: true, completion: { _ in });
                    }
                });
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.hideKeyboardWhenTappedAround();
        if (postDestination.count == 0) {
            destination.text.append("You have no groups added. You must select at least one post destination");
        }
        else {
            for text in postDestination {
                if (text == postDestination[0]) {
                    destination.text = text;
                }
                else {
                    destination.text.append(", \(text)");
                }
            }
        }
    }
}

class SelectGroup: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var ref:FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad();
        self.hideKeyboardWhenTappedAround();
        ref = FIRDatabase.database().reference();
        loadData();
        
        // set up tableviewcells
        let cellReuseIdentifier = "cell";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allgroups.count;
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GroupCell = self.tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell;
        cell.groupName.text = String(allgroups[indexPath.row]);
        if postDestination.contains(String(allgroups[indexPath.row])) {
            cell.cellState.image = #imageLiteral(resourceName: "check");
        }
        return cell;
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupJoin = allgroups[indexPath.row];
        let cell = self.tableView.cellForRow(at: indexPath) as! GroupCell;
        if (cell.cellState.image == #imageLiteral(resourceName: "check")) {
            cell.cellState.image = nil;
            postDestination = postDestination.filter {$0 != groupJoin}
        }
        else {
            cell.cellState.image = #imageLiteral(resourceName: "check");
            postDestination.append(groupJoin);
        }
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func loadData() {
        self.ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            let counter = snapshot.childrenCount - 1;
            // Clearing data from previous group array
            allgroups.removeAll();
            groupDescription2.removeAll();
            
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same:String = (snapshot.value! as? String) {
                        groupDescription2.append(same);
                    }
                });
                self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same:String = (snapshot.value! as? String) {
                        allgroups.append(same);
                        
                        if (allgroups.count == Int(counter)) {
                            self.tableView.reloadData();
                        }
                    }
                });
            }
        }
    }
    
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appFunctions().navigateTabController(index: 1, sIdentifier: "newPost", segue: segue);
    }
}

class GroupCell: UITableViewCell {
    @IBOutlet var groupName: UILabel!
    @IBOutlet var cellState: UIImageView!
}
