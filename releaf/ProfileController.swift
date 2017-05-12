//
//  GroupViewController.swift
//  releaf
//
//  Created by Emily on 3/28/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var restaurantNames = [String]() // lul groups

class GroupViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var nameField: UILabel!
    var tempFirst = " "
    var tempLast = " "
    @IBOutlet var tableView: UITableView!
    @IBOutlet var revealPoints: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    @IBAction func editPhoto(_ sender: Any) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //get image thing
        print("haeoijfaociweacmwiejcmaowiecmaowiec")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        
        imageView.image = chosenImage
        
        //base64 thing
        let imageData: Data! = UIImageJPEGRepresentation(chosenImage, 0.1)
        
        let base64String = (imageData as NSData).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("base64string").setValue(base64String)
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil);
    }

    
    
    var ref:FIRDatabaseReference!
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
//        
        let cellReuseIdentifier = "cell"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
//
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        
//        let userID = FIRAuth.auth()!.currentUser!.uid
        
        // set name
        self.ref.child("users").child(userID).child("firsasdfadsftName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.tempFirst = String(describing: snapshot.value!)
            print(snapshot.value!)
        })
        self.ref.child("users").child(userID).child("lastName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.tempLast = String(describing: snapshot.value!)
            print(snapshot.value!)
            self.nameField.text = self.tempFirst + " " + self.tempLast
        })

        // set reveal points
        self.ref.child("users").child(userID).child("revealPoints").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value!)
            self.revealPoints.text = "IMPACTS POINTS: \(snapshot.value!)"
        })
        
        
        // check if profile picture exists, if not set to the thing
        self.ref.child("users").child(userID).child("base64string").observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot.value!)
            if var same:String = (snapshot.value! as? String) {
                if (same == "default") { // works
                    self.imageView.image = #imageLiteral(resourceName: "guy")
                    print("set at default")
                }
                else { // doesn't work
                    
                    print("custom image")
                    let endIndex = same.index(same.endIndex, offsetBy: 0)
                    var truncated = same.substring(to: endIndex)
                    let newString = truncated.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)
                    let dataDecoded:Data = Data(base64Encoded: same, options: .ignoreUnknownCharacters)!
                    let image = UIImage(data: dataDecoded)!
                    self.imageView.image = image
                }
            }
        })
        checking()
    }
    
    func checking() {
        ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observe(.value, with: {      snapshot in
            if (restaurantNames.count == Int(snapshot.childrenCount)) { // array is missing data
                self.tableView.reloadData()
            }
            else { // array has all data
                for restaurant in snapshot.children { // append data
                    restaurantNames.append((restaurant as AnyObject).value!)
                    if (restaurantNames.count == Int(snapshot.childrenCount)) {
                        print("done")
                        print(restaurantNames)
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    private func base64PaddingWithEqual(encoded64: String) -> String {
        let remainder = encoded64.characters.count % 4
        if remainder == 0 {
            return encoded64
        } else {
            // padding with equal
            let newLength = encoded64.characters.count + (4 - remainder)
            return encoded64.padding(toLength: newLength, withPad: "=", startingAt: 0)
//            return encoded64.stringByPaddingToLength(newLength, withString: "=", startingAtIndex: 0)
        }
    }
    
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:GroupTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
        //        cell.prompt.text = String(groups[indexPath.row])
        cell.groupText.text = String(restaurantNames[indexPath.row])
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        var textToFind = String(restaurantNames[indexPath.row])
        print(textToFind)
        
        groupDetailsTitle = textToFind!
        
        //navigate back to home screen
        var ivc = self.storyboard?.instantiateViewController(withIdentifier: "GroupDetailsController")
        ivc?.modalPresentationStyle = .custom
        ivc?.modalTransitionStyle = .crossDissolve
        self.present(ivc!, animated: true, completion: { _ in })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class GroupTableViewCell: UITableViewCell {
    @IBOutlet var groupText: UILabel!
}

