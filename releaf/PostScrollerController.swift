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

class PostsController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    var ref:FIRDatabaseReference!
    @IBOutlet var staticPostText: UITextView!
    
    func loadData(){
        ref = FIRDatabase.database().reference();
        ref.child("post").child(String(currentIndex)).child("reply").observeSingleEvent(of: .value, with: { snapshot in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                guard let restDict = rest.value as? [String: Any] else { continue }
                let action = restDict["text"] as? String;
                let like = restDict["likes"] as? Int;
                if (rest.key != "0") {
                    replies.append(action!);
                    leaves.append(like!);
                }
            }
            self.tableView.reloadData();
        });
        ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            self.staticPostText.text = String(describing: snapshot.value!);
        }
    }
    
    @IBAction func nextPost_isPressed(_ sender: Any) {
        ref = FIRDatabase.database().reference();
        ref.child("post").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            let randomNum = arc4random_uniform(UInt32(snapshot.childrenCount));
            currentIndex = Int(randomNum);
        
            replies.removeAll();
            leaves.removeAll();
            uid.removeAll();
            
            self.tableView.reloadData();
            self.loadData();
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBAction func meToo_isPressed(_ sender: Any) {
        // checks me toos
        ref = FIRDatabase.database().reference();
        self.ref.child("post").child(String(currentIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same : String = (snapshot.value! as? String) {
                        if checkmetoos.contains(FIRAuth.auth()!.currentUser!.uid) { // exists

                            // unliking and liking posts
                            self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value {
                                    let same: Int = int as! Int
                                    if (same > 0){ // revealpoints greater than 0
                                        // if user revealpoints are greater than 0...
                                        let alertController = UIAlertController(title: "Error", message: "You've already reacted to this post.", preferredStyle: .alert);
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                                        alertController.addAction(defaultAction);
                                        self.present(alertController, animated: true, completion: nil);
                                    }
                                    else { // can't subtract
                                        let alertController = UIAlertController(title: "Error", message: "You can't remove your reaction from this post.", preferredStyle: .alert);
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                                        alertController.addAction(defaultAction);
                                        self.present(alertController, animated: true, completion: nil);
                                    }
                                }
                            }
                        }
                        else {
                            // Add to original poster's notifactions
                            self.ref.child("post").child(String(currentIndex)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                let originalPoster = snapshot.value
                                self.ref.child("users").child(originalPoster as! String).child("notification").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let int = (snapshot.value) {
                                        let same = (String((int as AnyObject).count)) as String!
                                        self.ref.child("users").child(originalPoster as! String).child("notification").child(same!).setValue([
                                            "action" : "me too",
                                            "post"   : currentIndex,
                                            "user"   : userID,
                                        ] as NSDictionary);
                                    }
                                });
                            }
                            
                            // Alert Prompt
                            let alert = UIAlertController(title: "React to Post", message: "You are about to react to this post.",preferredStyle: .alert)
                            let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                                appFunctions().incrementPoints();
                                print(checkmetoos)
                                checkmetoos.append(userID)
                                self.ref.child("post").child(String(currentIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(snapshot.childrenCount)).setValue(userID);
                                }
                                self.ref.child("users").child(userID).child("favorites").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("users").child(userID).child("favorites").child(String(snapshot.childrenCount)).setValue(currentIndex);
                                }
                                self.tableView.reloadData();
                            });
                            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
                            alert.addAction(cancel);
                            alert.addAction(submitAction);
                            self.present(alert, animated: true, completion: nil);
                        }
                    }
                });
            }
        }
    }
    
    @IBAction func hugs_isPressed(_ sender: Any) {
        ref = FIRDatabase.database().reference();
        self.ref.child("post").child(String(currentIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("post").child(String(currentIndex)).child("hugs").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same:String = (snapshot.value! as? String) {
                        if checkhugs.contains(FIRAuth.auth()!.currentUser!.uid) {
                            // unliking and liking posts
                            self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                if let int = snapshot.value {
                                    let same: Int = int as! Int;
                                    if (same > 0){
                                        let alertController = UIAlertController(title: "Error", message: "You've already reacted to this reply.", preferredStyle: .alert);
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                                        alertController.addAction(defaultAction);
                                        self.present(alertController, animated: true, completion: nil);
                                    }
                                    else {
                                        let alertController = UIAlertController(title: "Error", message: "You can't unlike this post.", preferredStyle: .alert);
                                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                                        alertController.addAction(defaultAction);
                                        self.present(alertController, animated: true, completion: nil);
                                    }
                                }
                            }
                        }
                        else {
                            // Add to original poster's notifactions
                            self.ref.child("post").child(String(currentIndex)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                let originalPoster = snapshot.value
                                self.ref.child("users").child(originalPoster as! String).child("notification").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let int = (snapshot.value) {
                                        let same = (String((int as AnyObject).count)) as String!
                                        self.ref.child("users").child(originalPoster as! String).child("notification").child(same!).setValue([
                                            "action" : "hug",
                                            "post"   : currentIndex,
                                            "user"   : userID,
                                        ] as NSDictionary);
                                    }
                                });
                            }
                            
                            // Alert Prompt
                            let alert = UIAlertController(title: "React to Post", message: "You are about to react to this post",preferredStyle: .alert)
                            let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
                                appFunctions().incrementPoints();
                                checkhugs.append(userID)
                                self.ref.child("post").child(String(currentIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("post").child(String(currentIndex)).child("hugs").child(String(snapshot.childrenCount)).setValue(userID);
                                }
                                self.tableView.reloadData();
                            });
                            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in });
                            alert.addAction(cancel);
                            alert.addAction(submitAction);
                            self.present(alert, animated: true, completion: nil);
                        }
                    }
                });
            }
        }
    }
    
    // revealing user identities
    @IBAction func userReveal(_ sender: Any) {
        // Alert Prompt
        
        let alert = UIAlertController(title: "Reveal User", message: "You are about to use one impact point to see the user of this post.",preferredStyle: .alert);
        let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in
            var indexPath: IndexPath!
            if let button = sender as? UIButton {
                if let superview = button.superview {
                    if let cell = superview.superview as? PromptTableViewCell {
                        indexPath = self.tableView.indexPath(for: cell) as IndexPath!
                        self.ref = FIRDatabase.database().reference();
                    self.ref.child("post").child(String(currentIndex)).child("reply").child(String(indexPath.row)).child("user").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        // get how many replies there are
                        let newstring = String(describing: snapshot.value!);
                        
                        // subtract one from reveal points
                        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if let int = snapshot.value{
                                if (int as! Int > 0) {
                                    let same = (int as! Int) - 1;
                                    self.ref.child("users").child(userID).child("revealPoints").setValue(same);
                                    
                                    // retrieve first name
                                    self.ref.child("users").child(newstring).child("firsasdfadsftName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                        if let int = snapshot.value {
                                            let first = int as! String;
                                            self.ref.child("users").child(newstring).child("lastName").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                                if let int = snapshot.value {
                                                    let last = int as! String
                                                    cell.username.text = first + " " + last;
                                                }
                                            }
                                        }
                                    }
                                }
                                else {
                                    let alertController = UIAlertController(title: "Error", message: "Not enough impact points.", preferredStyle: .alert);
                                    
                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                                    alertController.addAction(defaultAction);
                                    
                                    self.present(alertController, animated: true, completion: nil);
                                }
                            }
                        }

                    }
                }
            }
        }
        });
        alert.addAction(submitAction);
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in });
        alert.addAction(cancel);

        present(alert, animated: true, completion: nil);
    }
    
    func loadReactionArrays(){
        
        // Me Too Array
        ref.child("post").child(String(currentIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value : String = (snapshot.value! as? String) {
                        checkmetoos.append(value);
                    }
                });
            }
        }
        
        // Hugs Array
        ref.child("post").child(String(currentIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("post").child(String(currentIndex)).child("hugs").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value : String = (snapshot.value! as? String) {
                        checkhugs.append(value);
                    }
                });
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.hideKeyboardWhenTappedAround();
        Reachability.registerListener();
        
        // Not first load
        if (replies.count > 0) {
            ref = FIRDatabase.database().reference();
            ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                self.staticPostText.text = String(describing: snapshot.value!);
            }
        }
        else {
            loadData();
        }
    
        // set up the tableView
        let cellReuseIdentifier = "cell";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
    }
    
    // Determine whether the user has already liked the post
    func checkUIDArray(replyNumber:Int) {
        var uidArray: [String] = [];
        ref = FIRDatabase.database().reference();
        ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {
                
            let childCount = snapshot.childrenCount - 1;
            self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("uid").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    uidArray.append(snapshot.value! as! String)
                    if (uidArray.count == Int(childCount + 1)) {
                        
                        // Exists already -> cannot like
                        if uidArray.contains(FIRAuth.auth()!.currentUser!.uid) {
                            let alertController = UIAlertController(title: "Error", message: "You've already liked this reply.", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                            
                        // Does not exist in array -> can execute like
                        else {
                            let alertController = UIAlertController(title: "Like Response", message: "You are about to like this response.", preferredStyle: .alert);

                            let submitAction = UIAlertAction(title: "Confirm", style: .default, handler: { (action) -> Void in

                                // Add to Reply UID tracking
                                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("uid").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("uid").child(String(snapshot.childrenCount)).setValue(userID);
                                }

                                // Add to Reply Likes
                                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("likes").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                                    if let int = snapshot.value {
                                        let same = (int as! Int) + 1;
                                        self.ref.child("post").child(String(currentIndex)).child("reply").child(String(replyNumber)).child("likes").setValue(same);
                                    }
                                }
                                
                                appFunctions().incrementPoints();
                                self.tableView.reloadData();
                            });
                            
                            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in });
                            alertController.addAction(cancel);
                            alertController.addAction(submitAction);
                            self.present(alertController, animated: true, completion: nil);
                        }
                    }
                });
            }
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaves.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : PromptTableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "PromptTableViewCell") as? PromptTableViewCell
        if (cell == nil) {
            cell = PromptTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "PromptTableViewCell");
            cell?.selectionStyle = UITableViewCellSelectionStyle.none;
        }
        
        cell?.prompt?.sizeToFit();
        cell?.prompt?.text = replies[indexPath.row];
        cell?.prompt?.numberOfLines = 0

        cell?.leaves?.text = String(leaves[indexPath.row]);
        
        return cell!;
    }
    
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)];
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes);
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 200.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil);
        let requredSize:CGRect = rect;
        return requredSize.height;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (replies.count != 0) {
            let height:CGFloat = calculateHeight(inString: String(replies[indexPath.row]))
            return height + 20.0
        }
        return 44;
    }

    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkUIDArray(replyNumber: (indexPath.row));
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toReply") {
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard));
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap);
    }
    
    func dismissKeyboard() {
        view.endEditing(true);
    }
}
