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
var groupPathPost: String! // the group to post the new post to
var groupPosts: [String] = [] // the group's posts

class GroupDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var groupName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        self.groupName.text = groupDetailsTitle
        
        
        var textToFind2 = groupDetailsTitle
        
        self.ref.child("groups").queryOrdered(byChild: "name").queryEqual(toValue:textToFind2).observe(.value, with: { snapshot in
            if (snapshot.value is NSNull) {
                print("Skillet was not found")
            }
            else {
                for child in snapshot.children {   //in case there are several skillets
                    let key = (child as AnyObject).key as String
                    groupPathPost = key
                    print("GROUPINDEX:\(groupPathPost)") // gets key of post
                    self.groupPostChecking() // load data
                }
            }
        })
        
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func groupPostChecking() {
        ref.child("groups").child(String(groupPathPost)).child("post").observe(.value, with: {      snapshot in
            var count = Int(snapshot.childrenCount-1)
            for i in 1...snapshot.childrenCount-1 { // iterate from post 1
                print("POSTINDEX:\(i)")
                print("GROUPPATH:\(groupPathPost)")
                // append all the post text
                self.ref.child("groups").child(groupPathPost).child("post").child(String(i)).child("text").observe(.value, with: {      snapshot in
                    groupPosts.append(snapshot.value as! String)
                    if (groupPosts.count == count) { // array is missing data
                        self.tableView.reloadData()
                        print(groupPosts)
                    }
                })
            }
//            if (groupPosts.count == Int(snapshot.childrenCount)) { // array is missing data
//                self.tableView.reloadData()
//            }
//            else { // array has all data
//                for restaurant in snapshot.children { // append data
//                    groupPosts.append((restaurant as AnyObject).value!)
//                    if (groupPosts.count == Int(snapshot.childrenCount)) {
//                        print("done refreshing")
//                        self.tableView.reloadData()
//                    }
//                }
//            }
        })
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupPosts.count
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
        cell?.postText?.text = groupPosts[indexPath.row]
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
        var height:CGFloat = calculateHeight(inString: String(groupPosts[indexPath.row]))
        return height + 40.0
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // switches to createnewpost
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
            
//            var textToFind = groupDetailsTitle
//            self.ref.child("groups").queryOrdered(byChild: "name").queryEqual(toValue:textToFind).observe(.value, with: { snapshot in
//                if (snapshot.value is NSNull) {
//                    print("Skillet was not found")
//                }
//                else {
//                    for child in snapshot.children {   //in case there are several skillets
//                        let key = (child as AnyObject).key as String
//                        print("The key is\(key)") // gets key of post
//                        groupPathPost = Int(key)!
//                    }
//                }
//            })
            
            groupPosts.removeAll() // remove posts from array in preparation for new group
            
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
