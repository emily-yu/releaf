//
//  Explore.swift
//  releaf
//
//  Created by Emily on 8/17/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ExploreController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        loadData()
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // Retrieve list of groups
    func loadData() {
        self.ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            // Clearing data from previous group array
            allgroups.removeAll();
            groupDescription2.removeAll();
            groupMemberCount.removeAll();
            
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same:String = (snapshot.value! as? String) {
                        groupDescription2.append(same);
                    }
                });
                self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same:String = (snapshot.value! as? String) {
                        allgroups.append(same);
                    }
                });
                self.ref.child("groups").child(String(index)).child("member").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same: Int = (snapshot.value! as? Int) {
                        print("hey its me")
                        print(same)
                        groupMemberCount.append(same);
                        print("asdf")
                        self.tableView.reloadData();
                    }
                });
            }
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMemberCount.count;
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:ExploreCell? = tableView.dequeueReusableCell(withIdentifier: "ExploreCell") as? ExploreCell;
        
        if(cell == nil) {
            cell = ExploreCell(style:UITableViewCellStyle.default, reuseIdentifier: "ExploreCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        cell?.groupName.text = allgroups[indexPath.row];
        cell?.descr.text = groupDescription2[indexPath.row];
        cell?.members.text = "\(groupMemberCount[indexPath.row]) members";
        
        return cell!;
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let textToFind = String(allgroups[indexPath.row])
            groupDetailsTitle = textToFind!
            
            tableView.deselectRow(at: indexPath, animated: true);

            let ivc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailsController")
            ivc?.modalPresentationStyle = .custom
            ivc?.modalTransitionStyle = .crossDissolve
            self.present(ivc!, animated: true, completion: { _ in })
    }
    
}

class ExploreCell: UITableViewCell {
    @IBOutlet var groupName: UILabel!
    @IBOutlet var descr: UILabel!
    @IBOutlet var members: UILabel!
}
