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
            // TODO: Check if removing array contents is necessary
            // Retrieving notification information
            notifImage.removeAll()
            notifText.removeAll()
            notifUser.removeAll()
            for index in 1...snapshot.childrenCount-1 {
                print(index)
                let countingpat2 = snapshot.childrenCount
            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").child(String(index)).child("action").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same: String = (snapshot.value! as? String) {
                        notifImage.append(same)
                    }
                })
            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").child(String(index)).child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same: String = (snapshot.value! as? String) {
                        notifText.append(same)
                    }
                })
            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").child(String(index)).child("user").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same: String = (snapshot.value! as? String) {
                        notifUser.append(same)
                        print(notifUser.count)
                        print(countingpat2-1)
                        if (notifUser.count == Int(countingpat2-1)) {
                            print("TEXT\(notifText)")
                            print("USER\(notifUser)")
                            self.tableView.reloadData()
                        }
                    }
                })
            }
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
        
        // TODO: Cut off previews of posts at certain points so don't have to mess with autolayout
        // TODO: Remove notifications after the user closes the app
        // TODO: Clicking the notification takes you to the post in the post scroller
        self.ref.child("users").child(notifUser[indexPath.row]).child("firsasdfadsftName").observeSingleEvent(of: .value, with: { (snapshot) in
            if let same: String = (snapshot.value! as? String) {
                switch(notifImage[indexPath.row]) {
                    case "hug":
                        self.ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if let same2: String = (snapshot.value! as? String) {
                                cell?.detail?.text = "\(same) has given you a hug for your post, \(same2)";
                            }
                        }
                        break;
                    case "like":
                        self.ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if let same2: String = (snapshot.value! as? String) {
                                cell?.detail?.text = "\(notifText[indexPath.row]) has liked your reply in response to the post, \(same2)";
                            }
                        }
                        break;
                    case "me too":
                        self.ref.child("post").child(String(currentIndex)).child("text").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                            if let same2: String = (snapshot.value! as? String) {
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
}

class NotificationCell: UITableViewCell {
    @IBOutlet var detail: UITextView!
    @IBOutlet var profileImage: UIImageView!
}
