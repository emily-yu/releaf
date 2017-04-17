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

// post stats
var posts: [String] = ["asdf"] // store all the posts
var replies: [String] = [] // temp store replies for certain post
var leaves: [Int] = [] // temp store LIKES for everything replies
var tempLikes: [Int] = []

var currentIndex = 0
var asdf = false

class PostsController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
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
                // appends all the likes in post replies to 'leaves' array
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
        
        // reload everything in the tableView for a new post
        replies.removeAll()
        leaves.removeAll()
        loadData()
        self.tableView.reloadData()
        
        // set up the tableView
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    @IBOutlet var tableView: UITableView!
    @IBAction func meToo_isPressed(_ sender: Any) {
    }
    
    // revealing user identities - right now only reveals user uid, CHECK ANON STATUS (IF FULLANON CANNOT REVEAL)
    @IBAction func userReveal(_ sender: Any) {
        // Alert Prompt
        let alert = UIAlertController(title: "Reveal User", message: "You are about to use one impact point to see the user of this post.",preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
            var indexPath: IndexPath!
            if let button = sender as? UIButton {
                if let superview = button.superview {
                    if let cell = superview.superview as? PromptTableViewCell {
                        indexPath = self.tableView.indexPath(for: cell) as IndexPath!
                        self.ref = FIRDatabase.database().reference()
                        self.ref.child("post").child(String(currentIndex)).child("reply").child(String(indexPath.row)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            // get how many replies there are
                        var newstring = String(describing: snapshot.value!)
                        
                        // subtract one from reveal points
                        self.ref.child("users").child(self.userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if let int = snapshot.value{
                                if (int as! Int > 0) {
                                    var same = (int as! Int)-1;// subtract one reveal point
                                    self.ref.child("users").child(self.userID).child("revealPoints").setValue(same) // set new value
                                    cell.username.text = newstring // change text
                                }
                                else {
                                    let alertController = UIAlertController(title: "Error", message: "Not enough impact points.", preferredStyle: .alert)
                                    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (replies.count > 0){
            print("not first load")
            ref = FIRDatabase.database().reference()
            ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                self.staticPostText.text = String(describing: snapshot.value!)
            }
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

    // checks to see if user is listed under the reply uid's
    func checkUIDArray(replyNumber:Int) {
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("uid").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:String = (snapshot.value! as? String) {
                        if uid.contains(FIRAuth.auth()!.currentUser!.uid) {
                            print("its dere no can do")
                            asdf = true
                            // unliking and liking posts
                            self.ref.child("users").child(self.userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value {
                                    var same: Int = int as! Int
                                    if (same > 0){ // revealpoints greater than 0
                                        // if user revealpoints are greater than 0...
                                        let alertController = UIAlertController(title: "Error", message: "You've already liked this reply. Would you like to unlike the post?", preferredStyle: .alert)
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        let submitAction = UIAlertAction(title: "Unlike", style: .default, handler: { (action) -> Void in
                                            // locate userid in array and delet
                                            if let index = uid.index(of:self.userID) {
                                                uid.remove(at: index)
                                            }
                                            // decrement
                                            self.decrementPoints()
                                        })
                                        alertController.addAction(defaultAction)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                    else { // can't subtract
                                        let alertController = UIAlertController(title: "Error", message: "You've already liked this reply.", preferredStyle: .alert)
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        alertController.addAction(defaultAction)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                        else {
                            print("not there")
                            asdf = false
                            // Alert Prompt
                            let alert = UIAlertController(title: "Like Post", message: "You are about to like this reply.",preferredStyle: .alert)
                            let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                                    self.incrementPoints() // add one to your points
                                    uid.append(same)
                                    print(uid)
                                    // add one to the reply's likes
                                    self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                        if let int = snapshot.value{
                                            var same = (int as! Int)+1;// add one reveal point
                                            self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("likes").setValue(same) // set new value
                                        }
                                    }
                                
                                    // reload Data - not sure if this is working
//                                    replies.removeAll()
//                                    leaves.removeAll()
//                                    self.loadData()
                                    self.tableView.reloadData()
                            })
                            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
                            alert.addAction(cancel)
                            alert.addAction(submitAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
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
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        checkUIDArray(replyNumber: (indexPath.row))
    }
    
    func incrementPoints() {
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                var same = (int as! Int)+1;// add one reveal point
                self.ref.child("users").child(self.userID).child("revealPoints").setValue(same) // set new value
            }
        }
    }
    
    func decrementPoints() {
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                var same = (int as! Int)-1;// add one reveal point
                self.ref.child("users").child(self.userID).child("revealPoints").setValue(same) // set new value
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


