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
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:ExploreCell? = tableView.dequeueReusableCell(withIdentifier: "ExploreCell") as? ExploreCell;
        
        if(cell == nil) {
            cell = ExploreCell(style:UITableViewCellStyle.default, reuseIdentifier: "ExporeCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        cell?.groupName.text = "{group-name}";
        cell?.members.text = "{members}";
        
        return cell!;
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

class ExploreCell: UITableViewCell {
    @IBOutlet var groupName: UILabel!
    @IBOutlet var members: UILabel!
}
