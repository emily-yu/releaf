//
//  Function.swift
//  releaf
//
//  Created by Emily on 8/3/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import Firebase

class appFunctions {
    
    
    // Store data for local app use
    var tempParameter = 0;
    var ref = FIRDatabase.database().reference();
    
    /* Retrieve singular bits of data from Firebase
     * @param {String} path - Path to retrieve data from
     * @param {Any} type - Data cast type to return
     * @returns {Any}
    */
    func retrieveInfoByPath(path: String, type: Any) -> Any {
        return 0;
    };
    
    /* Retrieve array of data from Firebase
     * @param {String} path - Path to retrieve data from
     * @param {Any} type - Data cast type to return
     * @returns {Any}
     */
    func retrieveInfoArrayByPath(path: String, type: Any) -> [Any] {
        self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            // TODO: Check if removing array contents is necessary
            // Retrieving notification information
//            notifImage.removeAll()
//            notifText.removeAll()
//            notifUser.removeAll()
//            self.ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("notification").observeSingleEvent(of: .value, with: { snapshot in
//                for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
//                    guard let restDict = rest.value as? [String: Any] else { continue }
//                    let action = restDict["action"] as? String
//                    let post = restDict["post"] as? Int
//                    let user = restDict["user"] as? String
//                    notifImage.append(action!)
//                    notifText.append(post!)
//                    notifUser.append(user!)
//                }
//                self.tableView.reloadData()
//            });
        }
        return [0];
    };
    
    /* Navigation through tab controller with transition
     * @param {Int} index - Index of tab to navigate to
     * @param {String} sIdentifier - Identifier of segue triggering navigation
     * @param {UIStoryboardSegue} segue - Segue triggering navigation
     */
    func navigateTabController(index: Int, sIdentifier: String,segue: UIStoryboardSegue) {
        if(segue.identifier == sIdentifier){
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = index
                tabVC.modalPresentationStyle = .custom
                tabVC.modalTransitionStyle = .crossDissolve
            }
        }
    };
    
    /* Creates and appends new instance of object referenced in Firebase
     * @param {String} path - Path of collection of objects
     */
    func createNew() {
    };

}

/* Reminder Purposes - Referencing:
 * let appReference = appFunctions().functionName();
 */
