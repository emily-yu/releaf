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
 high priority:
 
 bugs
  - tableview isn't going bakc to home controller
 
  - if 3 of facebook/gmail friends are part of a group - gives suggestions if they want to join groups 
     - put how many friends are in group next to group list
- api to retrieve facebook friends
- switching posts ensure doesn't land on same post
- me too / hugs reveal from my posts pages
- unjoin groups
- interact with a post you earn a point (response, me too, hug) and if posting something
 - reveal uses the impact points
 
 - impact and reveal same thign
- click to expand?
 
  - join and create groups
 - lcik on post go to it
  - when reclicking on the groups section, it reloads and reappends
  - add when clicking on cell it likes it, adds user so you can't relike it - if you reclick it removes your uid
 
 low priority:
  - fix broken replies table thing
  - adjust groups so people only see from a specific group
 
 extra things:
  - add save function in post scroller
  - saved posts
  - profile picture
  - facebook login
  - twitter login
  - edit profile details
*/

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
                print("index:" + String(index)) // indexes of the posts
                
                // appends all the text in post replies to 'replies' array
                self.ref.child("post").child(String(currentIndex)).child("reply").child(String(index)).child("text").observeSingleEvent(of: .value, with: { (snapshot) in
//                    print(snapshot.value!) // get text
//                    replies.append(snapshot.value! as! String)
//                    print(replies)
                })
            }
            
        }
        
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
