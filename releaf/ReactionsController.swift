//
//  ReactionsController.swift
//  releaf
//
//  Created by Emily on 4/11/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit

// Post Reactions
var metoo: [String] = []
class MeTooController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
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
        return restaurantNames.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeTooTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "MeTooTableViewCell") as! MeTooTableViewCell
        //        cell.prompt.text = String(groups[indexPath.row])
        cell.username.text = String(restaurantNames[indexPath.row])
        
        return cell
    }
}

class MeTooTableViewCell: UITableViewCell {
    @IBOutlet var username: UILabel!
}

var hugs: [String] = []
class HugsController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
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
        return restaurantNames.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:HugsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "HugsTableViewCell") as! HugsTableViewCell
        //        cell.prompt.text = String(groups[indexPath.row])
        cell.username.text = String(restaurantNames[indexPath.row])
        
        return cell
    }

}

class HugsTableViewCell: UITableViewCell {
    @IBOutlet var username: UILabel!
}
