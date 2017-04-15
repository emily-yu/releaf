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
var clickedIndex: Int!

class MyPostsController: UIViewController, UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    let userID = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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
        
        clickedIndex = indexPath.row
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var ivc = storyboard.instantiateViewController(withIdentifier: "postInfo")
        ivc.modalPresentationStyle = .custom
        ivc.modalTransitionStyle = .crossDissolve
        self.present(ivc, animated: true, completion: { _ in })
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

class MyPostsTableViewCell: UITableViewCell {
    @IBOutlet var postText: UILabel!
}

class PostDetailsController: UIViewController {
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        
    }
    // switches to profile tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "myPostsSegue"){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 2
                print("called")
            }
        }
    }
}


