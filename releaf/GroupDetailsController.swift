//
//  GroupDetailsController.swift
//  releaf
//
//  Created by Emily on 5/1/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var groupDetailsTitle = ""

class GroupDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var groupName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        self.groupName.text = groupDetailsTitle
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell:GroupDetailCells? = tableView.dequeueReusableCell(withIdentifier: "GroupDetailCells") as? GroupDetailCells;
        if(cell == nil)
        {
            cell = GroupDetailCells(style:UITableViewCellStyle.default, reuseIdentifier: "GroupDetailCells")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
//        cell?.postText?.font = UIFont.systemFont(ofSize: 15.0)
        cell?.postText?.sizeToFit()
        cell?.postText?.text = allgroups[indexPath.row]
        cell?.postText?.numberOfLines = 0
        return cell!;
    }
    func calculateHeight(inString:String) -> CGFloat
    {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.height
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = calculateHeight(inString: String(allgroups[indexPath.row]))
        return height + 40.0
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        tableView.deselectRow(at: indexPath, animated: true)
        
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
        if(segue.identifier == "groupPostSegue"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 1
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class GroupDetailCells: UITableViewCell {
    @IBOutlet var postText: UILabel!
}
