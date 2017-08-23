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
        self.ref.child("groups").observeSingleEvent(of: .value, with: { snapshot in
            let childCount = Int(snapshot.childrenCount - 1);
            if (childCount != groupMemberCount.count) {
                groupDescription2.removeAll()
                allgroups.removeAll()
                groupMemberCount.removeAll()
                for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    print(rest)
                    if (rest.key != "0") {
                        let action = restDict["description"] as? String
                        let desc = restDict["name"] as? String
                        let count = restDict["member"] as? Int
                        groupDescription2.append(action!)
                        allgroups.append(desc!)
                        groupMemberCount.append(count!)
                    }
                }
                self.tableView.reloadData()
            }
        });
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
