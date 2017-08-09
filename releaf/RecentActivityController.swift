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
            // TODO: CHECK IF THIS PART IS NECESSARY
            // Retrieving notification information
            notifImage.removeAll()
            notifText.removeAll()
            notifUser.removeAll()
            for index in 1...snapshot.childrenCount-1 {
                print(index)
                var countingpat2 = snapshot.childrenCount
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").child(String(index)).child("action").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same: String = (snapshot.value! as? String) {
                        notifImage.append(same)
                    }
                })
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").child(String(index)).child("post").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same: String = (snapshot.value! as? String) {
                        notifText.append(same)
                    }
                })
                self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").child(String(index)).child("user").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same: String = (snapshot.value! as? String) {
                        notifUser.append(same)
                        print(notifUser.count)
                        print(countingpat2-1)
                        if (notifUser.count == Int(countingpat2-1)) {
                            //                    print(notifImage)
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
        
        // TODO: INSERT PREVIEW FOR POST
        self.ref.child("users").child(notifUser[indexPath.row]).child("firsasdfadsftName").observeSingleEvent(of: .value, with: { (snapshot) in
            if var same: String = (snapshot.value! as? String) {
                switch(notifImage[indexPath.row]) {
                    case "hug":
                        cell?.detail?.text = "\(same) has given you a hug for your post, {insert a preview for post \(notifText[indexPath.row]) here!}";
                        break;
                    case "like":
                        cell?.detail?.text = "\(notifText[indexPath.row]) has liked your reply in response to the post, {insert a preview here again!}";
                        break;
                    case "me too":
                        cell?.detail?.text = "\(notifText[indexPath.row]) has responded 'me too' to your post, {insert a preview here!}";
                        break;
                    default:
                        print("Something bad happened and I don't know what but whatever!")
                        break;
                }
            }
        })
        
        self.ref.child("users").child(notifUser[indexPath.row]).child("base64string").observeSingleEvent(of: .value, with: { (snapshot) in
            if var same: String = (snapshot.value! as? String) {
                if (same != "default") {
                    let endIndex = same.index(same.endIndex, offsetBy: 0)
                    var truncated = same.substring(to: endIndex)
                    let newString = truncated.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)
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
