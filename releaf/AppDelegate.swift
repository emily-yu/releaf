//
//  AppDelegate.swift
//  releaf
//
//  Created by Emily on 3/11/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


/*
 
 - unjoin groups
 - adjust groups so people only see from a specific group
 - click to expand?
 - switching posts ensure doesn't land on same post
 - rejoin group twice

 - if 3 of facebook/gmail friends are part of a group - gives suggestions if they want to join groups
 - put how many friends are in group next to group list
 - api to retrieve facebook friends
 
*/


var uid:[String] = [] // need to set these values when loaddata()ing
var userID = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ref: FIRDatabaseReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        ref = FIRDatabase.database().reference()
        
        // get a list of all the groups - ref: JoinGroups
        ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {
                self.ref.child("groups").child(String(index)).child("description").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:String = (snapshot.value! as? String) {
                        groupDescription2.append(same)
                    }
                })
                self.ref.child("groups").child(String(index)).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                    if var same:String = (snapshot.value! as? String) {
                        allgroups.append(same)
                    }
                })
            }
        }
        
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
