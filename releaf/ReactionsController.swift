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

class MeTooController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.hideKeyboardWhenTappedAround();

        if (previousIndex == -1) {
            previousIndex = clickedIndex!
            loadData();
            self.tableView.reloadData();
        }
        else {
            if (previousIndex != clickedIndex) {
                loadData();
                self.tableView.reloadData();
            }
        }
        
        let cellReuseIdentifier = "cell";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);
        tableView.delegate = self;
        tableView.dataSource = self;

    }
    
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString;
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)];
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes);
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil);
        
        let requredSize:CGRect = rect;
        return requredSize.height;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metoo.count;
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MeTooTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "MeTooTableViewCell") as? MeTooTableViewCell;
        if (cell == nil) {
            cell = MeTooTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "MeTooTableViewCell");
            cell?.selectionStyle = UITableViewCellSelectionStyle.none;
        }
        cell?.username?.sizeToFit();
        cell?.username?.text = String(metoo[indexPath.row]);
        cell?.username?.numberOfLines = 0;
        
        return cell!;
    }

    func loadData() {
        ref = FIRDatabase.database().reference()
        print(String(describing: clickedIndex))
        ref.child("post").child(String(clickedIndex)).child("metoo").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("post").child(String(clickedIndex)).child("metoo").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let int = snapshot.value{
                        let same = int as! String;
                        metoo.append(same);
                        self.tableView.reloadData();
                    }
                });
            }
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMeTooSegue" || segue.identifier == "detailsBack"){
            if let tabVC = segue.destination as? UIViewController{
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
            }
        }
    }
}

class MeTooTableViewCell: UITableViewCell {
    @IBOutlet var username: UILabel!
}

class HugsController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad();
        
        loadData();
        self.tableView.reloadData();
        
        let cellReuseIdentifier = "cell";
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)];
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes);
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil);
        
        let requredSize:CGRect = rect;
        return requredSize.height;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hugs.count;
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: HugsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "HugsTableViewCell") as? HugsTableViewCell;
        if (cell == nil) {
            cell = HugsTableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "HugsTableViewCell");
            cell?.selectionStyle = UITableViewCellSelectionStyle.none;
        }
        cell?.username?.sizeToFit();
        cell?.username?.text = String(hugs[indexPath.row]);
        cell?.username?.numberOfLines = 0;
        
        return cell!;
    }
    
    func loadData() {
        ref = FIRDatabase.database().reference();
        ref.child("post").child(String(clickedIndex)).child("hugs").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(snapshot.childrenCount - 1) {
                self.ref.child("post").child(String(clickedIndex)).child("hugs").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let int = snapshot.value {
                        let same = int as! String;
                        hugs.append(same);
                        self.tableView.reloadData();
                    }
                });
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toHugsSegue") {
            if let tabVC = segue.destination as? UIViewController {
                tabVC.modalPresentationStyle = .custom;
                tabVC.modalTransitionStyle = .crossDissolve;
            }
        }
        else if (segue.identifier == "detailsBack") {
            if let tabVC = segue.destination as? UIViewController {
                tabVC.modalPresentationStyle = .custom;
                tabVC.modalTransitionStyle = .crossDissolve;
            }
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
    }
}


class HugsTableViewCell: UITableViewCell {
    @IBOutlet var username: UILabel!
}
