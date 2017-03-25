//
//  FirstViewController.swift
//  releaf
//
//  Created by Emily on 3/11/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

var troll: [Int] = [65, 62, 622, 42, 2, 6502, 65]

// post stats
var posts: [String] = ["asdf"] // store all the posts
var replies: [String] = [] // temp store replies for certain post
var leaves: [Int] = [] // temp store leaves for everything

var currentIndex = 0

class PostsController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    var ref:FIRDatabaseReference!
    
    @IBAction func nextPost_isPressed(_ sender: Any) {
//        let randomNum:UInt32 = arc4random_uniform(100) // range is 0 to 99
//        print(randomNum)
        
        ref = FIRDatabase.database().reference()
        ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in

            // post index to address
            let randomNum = arc4random_uniform(UInt32(((snapshot.value!) as AnyObject).count)) // range is 0 to 99
            print(randomNum)
            currentIndex = Int(randomNum) // set currentIndex to be this value
        }

    }
    @IBOutlet var tableView: UITableView!
    @IBAction func meToo_isPressed(_ sender: Any) {
        print("same")

        
        // set this to replies instead
        // gets indexes of posts
//        ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
//            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {
//                print("index:" + String(index)) // indexes of the posts
//                
//               
//                self.ref.child("post").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
//                    print(snapshot.value!)
//                    posts.append(snapshot.value! as! String)
//                    print(posts)
//                })
//            
//                self.ref.child("post").child(String(index)).child("leaves").observeSingleEvent(of: .value, with: { (snapshot) in
//                    print(snapshot.value!)
//                    leaves.append(snapshot.value! as! Int)
//                    print(leaves)
//                })
//                
//            }
//        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(currentIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            // get how many replies there are
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {
                print("index:" + String(index)) // indexes of the posts
                
                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value!) // get text
                    replies.append(snapshot.value! as! String)
                })
            }
            
        }
        print(replies)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(replies.count)
        print("sakefjalsdfjkladsf")
        return replies.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:PromptTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "PromptTableViewCell") as! PromptTableViewCell
        
        cell.prompt.text = String(replies[indexPath.row])
        cell.leaves.text = String(troll[indexPath.row])
        
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


