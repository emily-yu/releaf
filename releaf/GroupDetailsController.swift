//
//  GroupDetailsController.swift
//  releaf
//
//  Created by Emily on 5/1/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var groupName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        self.groupName.text = groupDetailsTitle
        
        
        let textToFind2 = groupDetailsTitle
        
        self.ref.child("groups").queryOrdered(byChild: "name").queryEqual(toValue:textToFind2).observe(.value, with: { snapshot in
            if (snapshot.value is NSNull) {
                print("Skillet was not found")
            }
            else {
                for child in snapshot.children {   //in case there are several skillets
                    let key = (child as AnyObject).key as String
                    groupPathPost = key
                    print("GROUPINDEX:\(groupPathPost)") // gets key of post
                    self.groupPostChecking() // load data
                }
            }
        })
        
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func groupPostChecking() {
        ref.child("groups").child(String(groupPathPost)).child("post").observe(.value, with: {      snapshot in
            let count = Int(snapshot.childrenCount-1)
            if (count > 0) { // gotta have posts in it
                for i in 1...snapshot.childrenCount-1 { // iterate from post 1
                    print("POSTINDEX:\(i)")
                    print("GROUPPATH:\(groupPathPost)")
                    // append all the post text
                    self.ref.child("groups").child(groupPathPost).child("post").child(String(i)).child("text").observe(.value, with: {      snapshot in
                        groupPosts.append(snapshot.value as! String)
                        if (groupPosts.count == count) { // array is missing data
                            self.tableView.reloadData()
                            print(groupPosts)
                        }
                    })
                }
            }
            else { // group has no posts
            }
        })
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupPosts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell:GroupDetailCells? = tableView.dequeueReusableCell(withIdentifier: "GroupDetailCells") as? GroupDetailCells;
        if(cell == nil)
        {
            cell = GroupDetailCells(style:UITableViewCellStyle.default, reuseIdentifier: "GroupDetailCells")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
//        cell?.postText?.font = UIFont.systemFont(ofSize: 15.0)
        cell?.postText?.sizeToFit()
        cell?.postText?.text = groupPosts[indexPath.row]
        cell?.postText?.numberOfLines = 0
        return cell!;
    }
    func calculateHeight(inString:String) -> CGFloat{
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
        let height:CGFloat = calculateHeight(inString: String(groupPosts[indexPath.row]))
        return height + 40.0
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let textToFind = String(groupPosts[indexPath.row])
        ref.child("groups").child(String(groupPathPost)).child("post").queryOrdered(byChild: "text").queryEqual(toValue:textToFind).observe(.value, with: { snapshot in
            if (snapshot.value is NSNull) {
                print("Skillet was not found")
            }
            else {
                for child in snapshot.children {
                    let key = (child as AnyObject).key as String
                    print("The key is\(key)") // gets key of post
                    clickedIndex = Int(key)
                    print(clickedIndex)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let ivc = storyboard.instantiateViewController(withIdentifier: "groupPostInfo")
                    ivc.modalPresentationStyle = .custom
                    ivc.modalTransitionStyle = .crossDissolve
                    self.present(ivc, animated: true, completion: { _ in })
                }
            }
        })
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // TODO: CREATE NOTIFICATION SUPPORT FOR GROUPS
    // switches to createnewpost
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        groupPosts.removeAll() // remove posts from array in preparation for new group
        appFunctions().navigateTabController(index: 2, sIdentifier: "profileSegue", segue: segue);
        appFunctions().navigateTabController(index: 3, sIdentifier: "createGroupSegue", segue: segue);
        appFunctions().navigateTabController(index: 1, sIdentifier: "groupPostSegue", segue: segue);
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class GroupDetailCells: UITableViewCell {
    @IBOutlet var postText: UILabel!
}


class GroupPostDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var ref: FIRDatabaseReference!
    var dataText:[String] = [] // store reply text
    var dataLikes:[Int] = [] // store likes
    
    @IBOutlet var postText: UITextView!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func userReveal(_ sender: UIButton) {
        let button = sender as UIButton
        let replyNumber = (self.tableView.indexPathForRow(at: sender.center)!).row
//        print(replyNumber.row)
        
        let alert = UIAlertController(title: "Reveal User", message: "You are about to use one impact point to see the user of this post.",preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
            var indexPath: IndexPath!
            if let button = sender as? UIButton {
                if let superview = button.superview {
                    if let cell = superview.superview as? GroupPostDetailsTableViewCell {
                        indexPath = self.tableView.indexPath(for: cell) as IndexPath!
                        self.ref = FIRDatabase.database().reference()
                        self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex-1)).child("reply").child(String(replyNumber+1)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
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
                                                        cell.userText.text = first + " " + last // change text
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
    
    // liking
    func checkUIDArray(replyNumber:Int) {
        var troll23: [String] = []
        ref = FIRDatabase.database().reference()
        ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex-1)).child("reply").child(String(replyNumber+1)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) { // IT DED HERE
                
                let countinggg = snapshot.childrenCount - 1
                self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex-1)).child("reply").child(String(replyNumber+1)).child("uid").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    troll23.append(snapshot.value! as! String)
                    if (troll23.count == Int(countinggg+1)) {
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
                                
                                self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex-1)).child("reply").child(String(replyNumber+1)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex-1)).child("reply").child(String(replyNumber+1)).child("uid").child(String(snapshot.childrenCount)).setValue(userID) // set value
                                    //                                    }
                                }
                                
                                // add one to the reply's likes
                                self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex-1)).child("reply").child(String(replyNumber+1)).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    if let int = snapshot.value{
                                        let same = (int as! Int)+1;// add one reveal point
                                        self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex-1)).child("reply").child(String(replyNumber+1)).child("likes").setValue(same) // set new value
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
                let same = (int as! Int)+1;// add one reveal point
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

        self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            let childCount = Int(snapshot.childrenCount - 1);
            self.ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in

//                if (childCount != notifImage.count) {
                    for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        guard let restDict = rest.value as? [String: Any] else { continue }
                        let text = restDict["text"] as? String
                        let like = restDict["likes"] as? Int
                        self.dataText.append(text!)
                        self.dataLikes.append(like!)
                    }
                self.tableView.reloadData();
//                }
            }
        }
            
        
        // set post text
        ref.child("groups").child(String(groupPathPost)).child("post").child(String(clickedIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            self.postText.text = String(describing: snapshot.value!)
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataText.count
    }
    
    func calculateHeight(inString:String) -> CGFloat {
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
        var cell:GroupPostDetailsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "GroupPostDetailsTableViewCell") as? GroupPostDetailsTableViewCell;
        if(cell == nil)
        {
            cell = GroupPostDetailsTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "GroupPostDetailsTableViewCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        cell?.replyText?.sizeToFit()
        cell?.replyText?.text = String(dataText[indexPath.row])
        cell?.replyText?.numberOfLines = 0
        
        cell?.likeText?.sizeToFit()
        cell?.likeText?.text = String(dataLikes[indexPath.row])
        cell?.likeText?.numberOfLines = 0
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "backButton") {
            if let tabVC = segue.destination as? UIViewController{
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
                print("called")
            }
        }
    }
    
}

class GroupPostDetailsTableViewCell: UITableViewCell {
    @IBOutlet var userText: UILabel!
    @IBOutlet var replyText: UILabel!
    @IBOutlet var likeText: UILabel!
}
