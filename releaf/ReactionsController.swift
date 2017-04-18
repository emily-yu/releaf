//
//  ReactionsController.swift
//  releaf
//
//  Created by Emily on 4/11/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// Post Reactions
var metoo: [String] = []
var previousIndex: Int = -1 // track whether the index has changed

class MeTooController: UIViewController, UITableViewDelegate,UITableViewDataSource {
        var ref: FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // handle changing posts - not working
        if (previousIndex == -1) {
            previousIndex = clickedIndex!
            loadData()
            self.tableView.reloadData()
        }
        else {
            if (previousIndex == clickedIndex) {
                print("index didn't change")
            }
            else {
                loadData()
                self.tableView.reloadData()
            }
        }
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metoo.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MeTooTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "MeTooTableViewCell") as! MeTooTableViewCell
        //        cell.prompt.text = String(groups[indexPath.row])
        cell.username.text = String(metoo[indexPath.row])
        
        return cell
    }
    
    // right now this is not using the index number of the post that's being clicked, but the index of the cell
    func loadData() {
        ref = FIRDatabase.database().reference()
        print(String(describing: clickedIndex))
        ref.child("post").child(String(clickedIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            print(snapshot.childrenCount) // get the number of children
            var indexesss: [Int] = []
            for index in 0...(snapshot.childrenCount - 1) {
                print("INDEX:\(index)")
                // changed that to clickedIndex
                self.ref.child("post").child(String(clickedIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    print(index)
                    if let int = snapshot.value{
                        var same = int as! String;
                        print(same) // gets all the names who said me too
                        metoo.append(same)
                        print(metoo)
                        self.tableView.reloadData()
                        print("reloaded")
                    }
                })
            }
        }
    }
}

class MeTooTableViewCell: UITableViewCell {
    @IBOutlet var username: UILabel!
}

var hugs: [String] = []
class HugsController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ref = FIRDatabase.database().reference()
//        // to see all people that said me too
//        print(String(describing: clickedIndex))
//        
//        // fix this shiiiiiit i hope its just internet but it isn't FUCKING LOADING
//        ref.child("post").child(String(clickedIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
//            print(snapshot.childrenCount) // get the number of children
//            // get how many me too gais there are
////            print(((snapshot.value!) as AnyObject).count - 1)
//            for index in 0...(snapshot.childrenCount - 1) {
//                // appends all the text in post replies to 'replies' array
//                print(index)
//                self.ref.child("post").child(String(currentIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
//                    print(snapshot.value)
//                    if let int = snapshot.value{
//                        var same = int as! String;
//                        print(same) // gets all the names who said me too
//                        metoo.append(same)
//                        print("METOO ARRAY")
//                        print(metoo)
//                        
//                        self.tableView.reloadData()
//                        print("reloaded")
//                    }
//                })
//            }
//        }
        
        loadData()
        self.tableView.reloadData()
        
        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hugs.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:HugsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "HugsTableViewCell") as! HugsTableViewCell
        cell.username.text = String(hugs[indexPath.row])
        
        return cell
    }
    
    // loads the right replies but need to find the index that the tableView's text 's index and use that to find the arrays - right now just uses the clickedIndex's replies which isn't the same
    func loadData() {
        ref = FIRDatabase.database().reference()
        // to see all people that said me too
        print(String(describing: clickedIndex))
        ref.child("post").child(String(clickedIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            print(snapshot.childrenCount) // get the number of children
            // get how many me too gais there are
            //            print(((snapshot.value!) as AnyObject).count - 1)
            for index in 0...(snapshot.childrenCount - 1) {
                // appends all the text in post replies to 'replies' array
                print(index)
                self.ref.child("post").child(String(currentIndex)).child("hugs").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    if let int = snapshot.value{
                        var same = int as! String;
                        print(same) // gets all the names who said me too
                        hugs.append(same)
                        self.tableView.reloadData()
                        print("reloaded")
                    }
                })
            }
        }
    }
}

class HugsTableViewCell: UITableViewCell {
    @IBOutlet var username: UILabel!
}
