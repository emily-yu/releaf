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

class MyPostsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ref = FIRDatabase.database().reference();
        
        // Append indexes of posts stored in user info, then using those indexes to retrieve their text
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            // Clearing data from previous posts
            myPostsText.removeAll();
            myposts.removeAll();
            
            // Retrieving indexes of posts in user info
            let numberChildren = snapshot.childrenCount;
            for childIndex in 0...numberChildren {
                self.ref.child("users").child(userID).child("myPosts").child(String(childIndex)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let index : Int = snapshot.value! as? Int {
                        myposts.append(index);
                        if (myposts.count == Int(numberChildren)) {
                            for postIndex in myposts {
                                self.ref.child("post").child(String(postIndex)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                                    myPostsText.append(snapshot.value! as! String);
                                    
                                    // Finish appending group text
                                    if (myPostsText.count == myposts.count) {
                                        self.tableView.reloadData();
                                    }
                                });
                            }
                        }
                    }
                });
            }
        }
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    // INIT: Calculate number of rows in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPostsText.count
    }
    
    // INIT: Create cell for each tableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MyPostsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "MyPostsTableViewCell") as? MyPostsTableViewCell;
        
        if (cell == nil) {
            cell = MyPostsTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "MyPostsTableViewCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        cell?.postText?.sizeToFit();
        cell?.postText?.text = String(myPostsText[indexPath.row]);
        cell?.postText?.numberOfLines = 0;
        
        return cell!;
    }
    
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString;
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)];
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil);
        let requredSize:CGRect = rect;
        
        return requredSize.height;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = calculateHeight(inString: String(myPostsText[indexPath.row]));
        return height + 40.0;
    }
    
    // INTERACTION: Cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let textToFind = String(myPostsText[indexPath.row]);
        let refPath = self.ref.child("post");
        
        refPath.queryOrdered(byChild: "text").queryEqual(toValue:textToFind).observe(.value, with: { snapshot in
            if (snapshot.value is NSNull) {
                print("Item was not found");
            }
            else {
                for child in snapshot.children {
                    let key = (child as AnyObject).key as String;
                    clickedIndex = Int(key)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let ivc = storyboard.instantiateViewController(withIdentifier: "postInfo");
                    ivc.modalPresentationStyle = .custom;
                    ivc.modalTransitionStyle = .crossDissolve;
                    self.present(ivc, animated: true, completion: { _ in });
                }
            }
        })
        tableView.deselectRow(at: indexPath, animated: true);
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
    
    // elements to not always show; check if their uid exists
    @IBOutlet var meToo: UIButton!
    @IBOutlet var hug: UIButton!
    @IBOutlet var backgroundInfoTitle: UILabel!
    
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
                            let newstring = String(describing: snapshot.value!)
                            
                            // subtract one from reveal points
                            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value{
                                    if (int as! Int > 0) {
                                        let same = (int as! Int)-1;// subtract one reveal point
                                        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("revealPoints").setValue(same) // set new value
                                        
                                        // retrieve first name
                                        self.ref.child("users").child(newstring).child("firsasdfadsftName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                            if let int = snapshot.value{
                                                let first = int as! String // first name
                                                
                                                // retrieve last name
                                                self.ref.child("users").child(newstring).child("lastName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                                    if let int = snapshot.value{
                                                        let last = int as! String
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
            for index in 0...(snapshot.childrenCount - 1) { // NULL WHEN NO POSTS - NULL ON
                
                let countinggg = snapshot.childrenCount - 1
                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("uid").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    troll23.append(snapshot.value! as! String)
                    if (troll23.count == Int(countinggg+1)) {
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
                                appFunctions().incrementPoints() // add one to your points
                                
                                // ADD TO THE THING
                                
                                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("uid").child(String(snapshot.childrenCount)).setValue(userID) // set value
                                    //                                    }
                                }
                                
                                // add one to the reply's likes
                                self.ref.child("post").child(String(clickedIndex)).child("reply").child(String(replyNumber)).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    if let int = snapshot.value{
                                        let same = (int as! Int)+1;// add one reveal point
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        loadData()
        
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(clickedIndex)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            if let value = snapshot.value {
                let uid = value as! String
                if (uid == userID) {
                    print(uid)
                    print(userID)
                    self.meToo.isHidden = false
                    self.hug.isHidden = false
                    self.backgroundInfoTitle.isHidden = false
                }
                else {
                    self.meToo.isHidden = true
                    self.hug.isHidden = true
                    self.backgroundInfoTitle.isHidden = true
                }
            }
        };
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func loadData(){
        ref = FIRDatabase.database().reference()
        print(clickedIndex)
        ref.child("post").child(String(clickedIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {             // get how many replies there are
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
        let height:CGFloat = calculateHeight(inString: String(dataText[indexPath.row]))
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
        appFunctions().navigateTabController(index: 2, sIdentifier: "myPostsSegue", segue: segue);
        appFunctions().navigateTabController(index: 2, sIdentifier: "toMyPostsSegue", segue: segue);
    }
}

class DetailsTableViewCell: UITableViewCell {
    @IBOutlet var replyText: UILabel!
    @IBOutlet var usernameText: UILabel!
    @IBOutlet var numberLikes: UILabel!
}


