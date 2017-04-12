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

class JoinController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(allgroups.count)
        print("sakefjalsdfjkladsf")
        return allgroups.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:JoinTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "JoinTableViewCell") as! JoinTableViewCell
        cell.groupName.text = String(allgroups[indexPath.row])
//
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // change imageview to a checkmark
        // if imageview.image = the plus image then add it, if not then have popup that says you have already joined this group
    }
//
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
    
    @IBOutlet var groupName: UITextField!
    @IBOutlet var groupDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
