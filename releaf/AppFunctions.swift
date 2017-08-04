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
    
    /* Retrieve singular bits of data from Firebase
     * @param {String} path - Path to retrieve data from
     * @param {Any} type - Data cast type to return
     * @returns {Any}
    */
    func retrieveInfoByPath(path: String, type: Any) -> Any {
        return 0;
    }
    
    /* Retrieve array of data from Firebase
     * @param {String} path - Path to retrieve data from
     * @param {Any} type - Data cast type to return
     * @returns {Any}
     */
    func retrieveInfoArrayByPath(path: String, type: Any) -> [Any] {
        return [0];
    }
    
    /* Navigation through tab controller with transition
     * @param {Int} index - Index of tab to navigate to
     * @param {UIStoryboardSegue} segue - Segue triggering navigation
     */
    func navigateTabController(index: Int, segue: UIStoryboardSegue) {
    }
    
    /* Creates and appends new instance of object referenced in Firebase
     * @param {String} path - Path of collection of objects
     */
    func createNew() {
    }

}

/* Reminder Purposes - Referencing:
 * let appReference = appFunctions().functionName();
 */
