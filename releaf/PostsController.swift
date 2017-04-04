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

var troll: [Int] = [65, 62, 622, 42, 2, 6502, 65, 65, 62, 622, 42, 2, 6502, 65, 65, 62, 622, 42, 2, 6502, 65, 65, 62, 622, 42, 2, 6502, 65, 65, 62, 622, 42, 2, 6502, 65, 65, 62, 622, 42, 2, 6502, 65, 65, 62, 622, 42, 2, 6502, 65]

// post stats
var posts: [String] = ["asdf"] // store all the posts
var replies: [String] = [] // temp store replies for certain post
var leaves: [Int] = [] // temp store LIKES for everything replies
var tempLikes: [Int] = []

var currentIndex = 0

class PostsController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    // ADD ME TOO AND HUGS FUNCTIONALITY
    
    var ref:FIRDatabaseReference!
    @IBOutlet var staticPostText: UITextView!
    
    // enumeration
    func loadData(){
        
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(currentIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            // get how many replies there are
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {
                
                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
//                    print(snapshot.value!)
                    replies.append(snapshot.value! as! String)
                })
                
                // appends all the likes in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
                    //                    print(snapshot.value!)
                    leaves.append(snapshot.value! as! Int)
                    print(leaves)
                    print(snapshot.value!)
                    
                    // Do any additional setup after loading the view, typically from a nib.
                    let cellReuseIdentifier = "cell"
                    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                })
            }
        }
        
        
        
        ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            self.staticPostText.text = String(describing: snapshot.value!)
        }
        
//        // Do any additional setup after loading the view, typically from a nib.
//        let cellReuseIdentifier = "cell"
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
//        tableView.delegate = self
//        tableView.dataSource = self
        
    }
    
    @IBAction func nextPost_isPressed(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in

            // post index to address
            let randomNum = arc4random_uniform(UInt32(((snapshot.value!) as AnyObject).count)) // range is 0 to 99
//            print(randomNum)
            currentIndex = Int(randomNum) // set currentIndex to be this value
            print(currentIndex)
        }
        
        // clear previous cells data
        replies.removeAll()
        leaves.removeAll()
        
//        self.tableView.reloadData()
        loadData()

    }
    @IBOutlet var tableView: UITableView!
    @IBAction func meToo_isPressed(_ sender: Any) {
        print("same")
// CHANGED STRUCTURE FOR THIS
        
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
        loadData()
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(replies.count)
        return leaves.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:PromptTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "PromptTableViewCell") as! PromptTableViewCell
        
        cell.prompt.text = String(replies[indexPath.row])
        cell.leaves.text = String(leaves[indexPath.row])
        print(leaves)
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        // ADD ONE TO LEAF COUNT
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


