//
//  MyPostsController.swift
//  releaf
//
//  Created by Emily on 3/28/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var myposts: [Int] = [] //indexes of posts
var myPostsText: [String] = []

class MyPostsController: UIViewController, UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    let userID = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        
        // append all the posts to myposts, then transfer to array
        ref.child("users").child(userID).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            // get how many posts you have
            for index in 0...(((snapshot.value!) as AnyObject).count) {
                
                // appends all the text in post replies to 'replies' array
            self.ref.child("users").child(self.userID).child("myPosts").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
//                    myposts.append(snapshot.value! as! String) // this line fkut ups
//                    print(myposts)
//                    self.ref.child("users").child(self.userID).child("weight").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:Int = (snapshot.value! as? Int) {
                        myposts.append(same)
                        print(myposts)
                        // acceses right posts and puts indexs in array
                        // use array posts to same
                            for index2 in myposts {
//                                self.ref.child("users").child(self.userID).child("groups").child(String(index2)).observeSingleEvent(of: .value, with: { (snapshot) in
//                                    print(snapshot.value!)
//                                })
                                self.ref.child("post").child(String(index2)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                                    let int = snapshot.value!
                                    print(int)
                                    myPostsText.append(int as! String)
                                    print(myPostsText)
                                    
                                    // set up tableview
                                    let cellReuseIdentifier = "cell"
                                    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
                                    self.tableView.delegate = self
                                    self.tableView.dataSource = self
                                    
                                })
                            }
                    }
                        // end getting info
                })
                
            
                }
            }
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(myPostsText.count)
        print("sakefjalsdfjkladsf")
        return myPostsText.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MyPostsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "MyPostsTableViewCell") as! MyPostsTableViewCell
//        cell.prompt.text = String(replies[indexPath.row])
        cell.postText.text = String(myPostsText[indexPath.row])
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            replies.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // action one
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            print("Edit tapped")
        })
        editAction.backgroundColor = UIColor.blue
        
        // action two
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            print("Delete tapped")
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [editAction, deleteAction]
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
