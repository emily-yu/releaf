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

class MyPostsController: UIViewController, UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        
        // append all the posts to myposts, then transfer to array
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            // get how many posts you have
            myPostsText.removeAll()
            myposts.removeAll()
            for index in 0...(((snapshot.value!) as AnyObject).count) {
                var countingpat2 = (((snapshot.value!) as AnyObject).count)
                self.ref.child("users").child(userID).child("myPosts").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:Int = (snapshot.value! as? Int) {
                        myposts.append(same)
                        print("count\(myposts)")
                        // acceses right posts and puts indexs in array
                        // use array posts to same
                                if (myposts.count == countingpat2) {
                                                            for index2 in myposts {
                                                                print("index:\(index2)")
                        
                        self.ref.child("post").child(String(index2)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                            let int = snapshot.value!
                            myPostsText.append(int as! String)
                            if (myPostsText.count == myposts.count) {
                                print("exiting")
                                print(myPostsText)
                                self.tableView.reloadData()
                            }
                        })
                                                            }
                        }
                    }
                })
            }
        }
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    
    // --------------- START ---------------
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPostsText.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell:MyPostsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "MyPostsTableViewCell") as? MyPostsTableViewCell;
        if(cell == nil)
        {
            cell = MyPostsTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "MyPostsTableViewCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        //        cell?.postText?.font = UIFont.systemFont(ofSize: 15.0)
        cell?.postText?.sizeToFit()
        cell?.postText?.text = String(myPostsText[indexPath.row])
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
        var height:CGFloat = calculateHeight(inString: String(myPostsText[indexPath.row]))
        return height + 40.0
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        var textToFind = String(myPostsText[indexPath.row])
        
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
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    // revealing users
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
                        self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(indexPath.row)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
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
    
    
    // checks to see if user is listed under the reply uid's
    func checkUIDArray(replyNumber:Int) {
        var troll23: [String] = []
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
                
                var countinggg = ((snapshot.value!) as AnyObject).count - 1
                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("uid").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    troll23.append(snapshot.value! as! String)
                    if (troll23.count == countinggg+1) {
                        print("FINISHED APPENDING")
                        print(troll23)
                        
                        if troll23.contains(FIRAuth.auth()!.currentUser!.uid) {
                            print("its dere no can do")
                            let alertController = UIAlertController(title: "Error", message: "You've already liked this reply.", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else {
                            print("not there lets go appendo")
                            let alertController = UIAlertController(title: "Like Response", message: "You are about to like this response.", preferredStyle: .alert)
                            let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                                self.incrementPoints() // add one to your points
                                
                                // ADD TO THE THING
                                
                                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("uid").child(String(snapshot.childrenCount)).setValue(userID) // set value
                                    //                                    }
                                }
                                
                                // add one to the reply's likes
                                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    if let int = snapshot.value{
                                        var same = (int as! Int)+1;// add one reveal point
                                        self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("likes").setValue(same) // set new value
                                    }
                                }
                                
                                self.tableView.reloadData()
                            })
                            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
                            alertController.addAction(cancel)
                            alertController.addAction(submitAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        checkUIDArray(replyNumber: (indexPath.row))
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func incrementPoints() {
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let int = snapshot.value{
                var same = (int as! Int)+1;// add one reveal point
                self.ref.child("users").child(userID).child("revealPoints").setValue(same) // set new value
            }
        }
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
    
    func loadData(){
        ref = FIRDatabase.database().reference()
        print(clickedIndex)
        ref.child("post").child(String(clickedIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {             // get how many replies there are
                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                        self.dataText.append(snapshot.value! as! String)
                })
                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(index)).child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    func calculateHeight(inString:String) -> CGFloat
    {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.height
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = calculateHeight(inString: String(dataText[indexPath.row]))
        return height + 40.0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:DetailsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "DetailsTableViewCell") as? DetailsTableViewCell;
        if(cell == nil)
        {
            cell = DetailsTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "DetailsTableViewCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        cell?.numberLikes?.sizeToFit()
        cell?.numberLikes?.text = String(dataLikes[indexPath.row])
        cell?.numberLikes?.numberOfLines = 0
        
        cell?.replyText?.sizeToFit()
        cell?.replyText?.text = String(dataText[indexPath.row])
        cell?.replyText?.numberOfLines = 0
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "myPostsSegue"){
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


