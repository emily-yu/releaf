//
//  RecentActivityController.swift
//  releaf
//
//  Created by Emily on 8/3/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NotificationController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref:FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaves.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:NotificationCell? = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as? NotificationCell;
        
        if(cell == nil) {
            cell = NotificationCell(style:UITableViewCellStyle.default, reuseIdentifier: "NotificationCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        cell?.group?.text = "same";
        cell?.detail?.text = "same2";
        cell?.profileImage?.image = #imageLiteral(resourceName: "guy");
        
        return cell!;
    }
    
}

class NotificationCell: UITableViewCell {
    @IBOutlet var group: UILabel!
    @IBOutlet var detail: UITextView!
    @IBOutlet var profileImage: UIImageView!
}
