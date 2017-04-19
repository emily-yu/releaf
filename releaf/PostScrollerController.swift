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

// checking
var checkhugs: [String] = []
var checkmetoos: [String] = []

var currentIndex = 0
var asdf = false

class PostsController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
//    let userID = FIRAuth.auth()!.currentUser!.uid
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
    @IBAction func meToo_isPressed(_ sender: Any) { // sets the arrays
        // checks me toos
        ref = FIRDatabase.database().reference()
        self.ref.child("post").child(String(currentIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:String = (snapshot.value! as? String) {
                        if checkmetoos.contains(FIRAuth.auth()!.currentUser!.uid) {
                            print("its dere no can do")
                            asdf = true
                            // unliking and liking posts
                            self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value {
                                    var same: Int = int as! Int
                                    if (same > 0){ // revealpoints greater than 0
                                        // if user revealpoints are greater than 0...
                                        let alertController = UIAlertController(title: "Error", message: "You've already reacted to this post.", preferredStyle: .alert)
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        alertController.addAction(defaultAction)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                    else { // can't subtract
                                        let alertController = UIAlertController(title: "Error", message: "You can't remove your reaction from this post.", preferredStyle: .alert)
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
                            let alert = UIAlertController(title: "React to Post", message: "You are about to react to this post.",preferredStyle: .alert)
                            let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                                self.incrementPoints() // add one to your points
                                print(checkmetoos)
                                checkmetoos.append(userID)
                                // ADD TO DATABASE TOO - should wokr?
                                self.ref.child("post").child(String(currentIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(snapshot.childrenCount)).setValue(userID) // set value
                                    //                                    }
                                }
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
    
    @IBAction func hugs_isPressed(_ sender: Any) {
        // checks me toos
        ref = FIRDatabase.database().reference()
        self.ref.child("post").child(String(currentIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                self.ref.child("post").child(String(currentIndex)).child("hugs").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:String = (snapshot.value! as? String) {
                        if checkhugs.contains(FIRAuth.auth()!.currentUser!.uid) {
                            print("its dere no can do")
                            asdf = true
                            // unliking and liking posts
                            self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value {
                                    var same: Int = int as! Int
                                    if (same > 0){ // revealpoints greater than 0
                                        // if user revealpoints are greater than 0...
                                        let alertController = UIAlertController(title: "Error", message: "You've already reacted to this reply.", preferredStyle: .alert)
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        alertController.addAction(defaultAction)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                    else { // can't subtract
                                        let alertController = UIAlertController(title: "Error", message: "You can't unlike this post.", preferredStyle: .alert)
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
                            let alert = UIAlertController(title: "React to Post", message: "You are about to react to this post",preferredStyle: .alert)
                            let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                                self.incrementPoints() // add one to your points
                                print(checkhugs)
                                checkhugs.append(userID)
                                // ADD TO DATABASE TOO - should wokr?
                                self.ref.child("post").child(String(currentIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    //                                    if let int = snapshot.value{
                                    //                                        var same = (int as! Int)+1;// add one reveal point
                                    self.ref.child("post").child(String(currentIndex)).child("hugs").child(String(snapshot.childrenCount)).setValue(userID) // set value
                                    //                                    }
                                }
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
    
    // revealing user identities
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
                        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if let int = snapshot.value{
                                if (int as! Int > 0) {
                                    var same = (int as! Int)-1;// subtract one reveal point
                                    self.ref.child("users").child(userID).child("revealPoints").setValue(same) // set new value
                                    
                                    // retrieve first name
                                    self.ref.child("users").child(newstring).child("firsasdfadsftName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                        if let int = snapshot.value{
                                            var first = int as! String // first name
                                            
                                            // retrieve last name
                                            self.ref.child("users").child(newstring).child("lastName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                                if let int = snapshot.value{
                                                    var last = int as! String
                                                    cell.username.text = first + " " + last // change text
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
    
    func loadReactionArrays(){
        // SET HUGS AND METOO ARRAYS
        // init metoo array
        ref.child("post").child(String(currentIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:String = (snapshot.value! as? String) {
                        checkmetoos.append(same)
                        print("METOOS:\(checkmetoos)")
                    }
                })
            }
        }
        // init hugs array
        ref.child("post").child(String(currentIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                self.ref.child("post").child(String(currentIndex)).child("hugs").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:String = (snapshot.value! as? String) {
                        checkhugs.append(same)
                        print("HGUGS\(checkhugs)")
                    }
                })
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        
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
                            self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value {
                                    var same: Int = int as! Int
                                    if (same > 0){ // revealpoints greater than 0
                                        // if user revealpoints are greater than 0...
                                        let alertController = UIAlertController(title: "Error", message: "You've already liked this reply. Would you like to unlike the post?", preferredStyle: .alert)
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                        let submitAction = UIAlertAction(title: "Unlike", style: .default, handler: { (action) -> Void in
                                            // locate userid in array and delet
                                            if let index = uid.index(of: userID) {
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
                self.ref.child("users").child(userID).child("revealPoints").setValue(same) // set new value
            }
        }
    }
    
    func decrementPoints() {
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                var same = (int as! Int)-1;// add one reveal point
                self.ref.child("users").child(userID).child("revealPoints").setValue(same) // set new value
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toReply"){
            if let tabVC = segue.destination as? UIViewController{
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


class PromptTableViewCell: UITableViewCell {
    @IBOutlet var prompt: UILabel!
    @IBOutlet var leaves: UILabel!
    @IBOutlet var username: UILabel!
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
