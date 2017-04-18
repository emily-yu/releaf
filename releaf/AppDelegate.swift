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
import GoogleSignIn


/*
 low priority:
 - unjoin groups
 - adjust groups so people only see from a specific group
 - click to expand?
 - switching posts ensure doesn't land on same post
 - rejoin group twice
 - refresh table when create new groups
 
 extra things:
  - facebook login
  - twitter login
  - edit profile details
 
 - if 3 of facebook/gmail friends are part of a group - gives suggestions if they want to join groups
 - put how many friends are in group next to group list
 - api to retrieve facebook friends
*/

var uid:[String] = []
var userID = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var ref: FIRDatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        ref = FIRDatabase.database().reference()
        ref.child("post").child(String(currentIndex)).child("reply").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            // get how many replies there are
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) {
                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
                })
            }
        }
        
//        var userID: String = FIRAuth.auth()!.currentUser!.uid
//        // set groups array
//        ref = FIRDatabase.database().reference()
//        
//        ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("groups").observe(.value, with: {
//            snapshot in
//            for restaurant in snapshot.children {
//                restaurantNames.append((restaurant as AnyObject).value!)
//            }
////            print(restaurantNames)
//        })
//        
//        // append all the posts to myposts, then transfer to array
//        ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("myPosts").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
//            // get how many posts you have
//            for index in 0...(((snapshot.value!) as AnyObject).count) { // NULL WHEN NO POSTS - NULL ON
//                
//                // appends all the text in post replies to 'replies' array
//                self.ref.child("users").child(userID).child("myPosts").child(String(index)).observeSingleEvent(of: .value, with: { (snapshot) in
//                    if var same:Int = (snapshot.value! as? Int) {
//                        myposts.append(same)
//                        // acceses right posts and puts indexs in array
//                        // use array posts to same
//                        for index2 in myposts {
//                            self.ref.child("post").child(String(index2)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
//                                let int = snapshot.value!
//                                myPostsText.append(int as! String)
//                            })
//                        }
//                    }
//                })
//            }
//        }
        
//         append all the posts to myposts, then transfer to array
        ref.child("groups").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for index in 0...(((snapshot.value!) as AnyObject).count - 1) { // NULL WHEN NO POSTS - NULL ON
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

        self.ref = FIRDatabase.database().reference()
        
        // Google Sign In
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    // google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                // ...
                return
            }
        }
        
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    // for 8.0 support
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
        
    // end sign in
        


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
