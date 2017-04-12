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
    let userID = FIRAuth.auth()!.currentUser!.uid
    var ref:FIRDatabaseReference!
    @IBOutlet var staticPostText: UITextView!
    
    func loadData(){
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(currentIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {             // get how many replies there are

                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                    replies.append(snapshot.value! as! String)
                })
                
                // appends all the likes in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
                    leaves.append(snapshot.value! as! Int)
                    self.tableView.reloadData()
                })
            }
        }
        
        ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            self.staticPostText.text = String(describing: snapshot.value!)
        }
    }
    
    @IBAction func nextPost_isPressed(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in

            // post index to address
            let randomNum = arc4random_uniform(UInt32(((snapshot.value!) as AnyObject).count)) // range is 0 to 99
            currentIndex = Int(randomNum) // set currentIndex to be this value
        }
        
        replies.removeAll()
        leaves.removeAll()
        loadData()
        self.tableView.reloadData()
        
        // set up the tableView
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        print(replies)
    }
    @IBOutlet var tableView: UITableView!
    @IBAction func meToo_isPressed(_ sender: Any) {
        print("same")

    }
    
    // revealing user identities
    @IBAction func userReveal(_ sender: Any) {
        // Alert Prompt
        let alert = UIAlertController(title: "Reveal User", message: "You are about to use one reveal point to see the user of this post.",preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
            var indexPath: IndexPath!
            if let button = sender as? UIButton {
                if let superview = button.superview {
                    if let cell = superview.superview as? PromptTableViewCell {
                        indexPath = self.tableView.indexPath(for: cell) as IndexPath!
                        self.ref = FIRDatabase.database().reference()
                        self.ref.child("post").child(String(currentIndex)).child("reply").child(String(indexPath.row)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            // get how many replies there are
                            print(snapshot.value!)
                            var newstring = String(describing: snapshot.value!)
                        
                        
                            // subtract one from reveal points
                            self.ref.child("users").child(self.userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                print(snapshot.value!)
                                if let int = snapshot.value{
                                    if (int as! Int > 0) {
                                        var same = (int as! Int)-1;// subtract one reveal point
                                        self.ref.child("users").child(self.userID).child("revealPoints").setValue(same) // set new value
                                        cell.username.text = newstring // change text
                                    }
                                    else {
                                        let alertController = UIAlertController(title: "Error", message: "Not enough reveal points.", preferredStyle: .alert)
                                        
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        alertController.addAction(defaultAction)
                                        
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }

                            }

                        }
                    }
                }
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(cancel)
        alert.addAction(submitAction)
        present(alert, animated: true, completion: nil)
    }
    
    // not connected to anything
    @IBAction func metooReveal(_ sender: Any) {
        
        // to see all people that said me too
        ref.child("post").child(String(currentIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            // get how many me too gais there are
            
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {
                
                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    //                        print(snapshot.value!)
                    if let int = snapshot.value{
                        var same = int as! String;
                        print(same) // gets all the names who said me too
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (replies.count > 0){
            print("not first load")
        }
        else {
            loadData()
        }
        // set up the tableView
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
        var cell:PromptTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "PromptTableViewCell") as! PromptTableViewCell
        
        cell.prompt.text = String(replies[indexPath.row])
        cell.leaves.text = String(leaves[indexPath.row])
        print(leaves)
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        // like a post
        // ADD ONE TO LEAF COUNT
        // add a point
        
    }
    
    // add one reveal point - CHECK IF UID IS ALREADY THERE
    func incrementPoints() {
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            print(snapshot.value!)
            if let int = snapshot.value{
                var same = (int as! Int)+1;// add one reveal point
                self.ref.child("users").child(self.userID).child("revealPoints").setValue(same) // set new value
            }
        }
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


