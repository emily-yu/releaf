//
//  RecentActivityController.swift
//  releaf
//
//  Created by Emily on 8/3/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NotificationController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref:FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        loadData()
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func loadData() {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            let childCount = Int(snapshot.childrenCount - 1);
            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").observeSingleEvent(of: .value, with: { snapshot in
                if (childCount != notifImage.count) {
                    notifImage.removeAll()
                    notifText.removeAll()
                    notifUser.removeAll()
                    for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        guard let restDict = rest.value as? [String: Any] else { continue }
                        let action = restDict["action"] as? String
                        let post = restDict["post"] as? Int
                        let user = restDict["user"] as? String
                        notifImage.append(action!)
                        notifText.append(post!)
                        notifUser.append(user!)
                    }
                    self.tableView.reloadData()
                }
            });
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifText.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:NotificationCell? = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as? NotificationCell;
        
        if(cell == nil) {
            cell = NotificationCell(style:UITableViewCellStyle.default, reuseIdentifier: "NotificationCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        // TODO: Clicking the notification takes you to the post in the post scroller
        self.ref.child("users").child(notifUser[indexPath.row]).child("firsasdfadsftName").observeSingleEvent(of: .value, with: { (snapshot) in
            if let same: String = (snapshot.value! as? String) {
                print(same)
                print(currentIndex)
                print(notifText)
                switch(notifImage[indexPath.row]) {
                    case "hug":
                        self.ref.child("post").child(String(notifText[indexPath.row])).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if var same2: String = (snapshot.value! as? String) {
                                if (same2.characters.count > 25) {
                                    same2 = same2.substring(to: same2.index(same2.startIndex, offsetBy: 25))
                                }
                                cell?.detail?.text = "\(same) has given you a hug for your post, \(same2)";
                            }
                        }
                        break;
                    case "like":
                        self.ref.child("post").child(String(notifText[indexPath.row])).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if var same2: String = (snapshot.value! as? String) {
                                if (same2.characters.count > 25) {
                                    same2 = same2.substring(to: same2.index(same2.startIndex, offsetBy: 25))
                                }
                                cell?.detail?.text = "\(same) has liked your reply in response to the post, \(same2)";
                            }
                        }
                        break;
                    case "me too":
                        self.ref.child("post").child(String(notifText[indexPath.row])).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if var same2: String = (snapshot.value! as? String) {
                                if (same2.characters.count > 25) {
                                    same2 = same2.substring(to: same2.index(same2.startIndex, offsetBy: 25))
                                }
                                cell?.detail?.text = "\(same) has responded 'me too' to your post, \(same2)";
                            }
                        }
                        break;
                    default:
                        print("Something bad happened and I don't know what but whatever!")
                        break;
                }
            }
        })
        
        self.ref.child("users").child(notifUser[indexPath.row]).child("base64string").observeSingleEvent(of: .value, with: { (snapshot) in
            if let same: String = (snapshot.value! as? String) {
                if (same != "default") {
                    let dataDecoded:Data = Data(base64Encoded: same, options: .ignoreUnknownCharacters)!
                    let image = UIImage(data: dataDecoded)!
                    cell?.profileImage?.image = image
                }
                else {
                    cell?.profileImage?.image = #imageLiteral(resourceName: "guy")
                }
                
            }
        })
        
        return cell!;
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.deleteFunction(childIWantToRemove: notifText[indexPath.row]);
            self.tableView.reloadData();
        })
        deleteAction.backgroundColor = UIColor(red:0.94, green:0.41, blue:0.31, alpha:1.0)
        return [deleteAction]
    }
    
    func deleteFunction(childIWantToRemove: Int) {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").child(String(childIWantToRemove)).removeValue { (error, ref) in
            if error != nil {
                print("error \(error)")
            }
        }
    }
}

class NotificationCell: UITableViewCell {
    @IBOutlet var detail: UITextView!
    @IBOutlet var profileImage: UIImageView!
}
