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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
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
        

        var textToFind = String(myPostsText[indexPath.row])
        print(textToFind)
//        let query = ref.child("posts").queryOrdered(byChild: "text").queryEqual(toValue: textToFind)
//        print(query.parent())
        
        let refPath = self.ref.child(byAppendingPath: "post")
//
        refPath.queryOrdered(byChild: "text").queryEqual(toValue:textToFind).observe(.value, with: { snapshot in
            if (snapshot.value is NSNull) {
                print("Skillet was not found")
            }
            else {
                for child in snapshot.children {   //in case there are several skillets
                    let key = (child as AnyObject).key as String
                    print("The key is\(key)") // gets key of post
                    clickedIndex = Int(key)
                    print(clickedIndex)
                    
                    var storyboard = UIStoryboard(name: "Main", bundle: nil)
                    var ivc = storyboard.instantiateViewController(withIdentifier: "postInfo")
                    ivc.modalPresentationStyle = .custom
                    ivc.modalTransitionStyle = .crossDissolve
                    self.present(ivc, animated: true, completion: { _ in })
                }
            }
        })
    }
}

class MyPostsTableViewCell: UITableViewCell {
    @IBOutlet var postText: UILabel!
}

class PostDetailsController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    var dataText:[String] = [] // store reply text
    var dataLikes:[Int] = [] // store likes
    
    @IBOutlet var postText: UITextView!
    @IBOutlet var postReplies: UITableView!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func userReveal(_ sender: Any) {
        
        // Alert Prompt
        let alert = UIAlertController(title: "Reveal User", message: "You are about to use one impact point to see the user of this post.",preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
            var indexPath: IndexPath!
            if let button = sender as? UIButton {
                if let superview = button.superview {
                    if let cell = superview.superview as? DetailsTableViewCell {
                        indexPath = self.tableView.indexPath(for: cell) as IndexPath!
                        self.ref = FIRDatabase.database().reference()
                        self.ref.child("post").child(String(currentIndex)).child("reply").child(String(indexPath.row)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            // get how many replies there are
                            var newstring = String(describing: snapshot.value!)
                            
                            // subtract one from reveal points
                            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value{
                                    if (int as! Int > 0) {
                                        var same = (int as! Int)-1;// subtract one reveal point
                                        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("revealPoints").setValue(same) // set new value
                                        
                                        // retrieve first name
                                        self.ref.child("users").child(newstring).child("firsasdfadsftName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                            if let int = snapshot.value{
                                                var first = int as! String // first name
                                                
                                                // retrieve last name
                                                self.ref.child("users").child(newstring).child("lastName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                                    if let int = snapshot.value{
                                                        var last = int as! String
                                                        cell.usernameText.text = first + " " + last // change text
                                                    }
                                                }
                                            }
                                            
                                        }
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
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        loadData()
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // haven't added user revealing yet
    func loadData(){
        ref = FIRDatabase.database().reference()
        print(clickedIndex)
        ref.child("post").child(String(clickedIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {             // get how many replies there are
                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                        self.dataText.append(snapshot.value! as! String)
                })
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
                        self.dataLikes.append(snapshot.value! as! Int)
                        self.tableView.reloadData()
                })
            }
        }
        
        // set post text
        ref.child("post").child(String(clickedIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            self.postText.text = String(describing: snapshot.value!)
            print(snapshot.value)
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataLikes.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: DetailsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell") as! DetailsTableViewCell
        cell.numberLikes.text = String(dataLikes[indexPath.row])
        cell.replyText.text = String(dataText[indexPath.row])
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "myPostsSegue"){ // don't know if segue exists
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 2
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
        else if (segue.identifier == "toMyPostsSegue") {
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 2
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
    }
}

class DetailsTableViewCell: UITableViewCell {
    @IBOutlet var replyText: UILabel!
    @IBOutlet var usernameText: UILabel!
    @IBOutlet var numberLikes: UILabel!
}


