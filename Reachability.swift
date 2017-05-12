//
//  Reachability.swift
//  releaf
//
//  Created by Emily on 5/11/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking

public class Reachability {
    private static let theSharedInstance:Reachability = Reachability();
    private var isClientOnline:Bool = true;
    private var isClientWiFi:Bool = false;
    private var isClientConnectionUnknown = false;
    
    var alertController = UIAlertController(title: "Error", message: "Network error (interrupted connection) has occurred. Please check your internet connection.", preferredStyle: .alert)
    let alertWindow = UIWindow(frame: UIScreen.main.bounds)
    
    func onOnline() {
        print("****************************************** Network goes online.");
//        alertController.dismiss(animated: true, completion: nil)
        alertWindow.isHidden = true
    }
    
    func onOffline() {
        print("****************************************** Network goes offline.");
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func onWiFi() {
        print("****************************************** Wifi network on");
    }
    
    func onGSM() {
        print("****************************************** GSM network on");
    }
    
    func onUnknownConnectionStatus() {
        print("****************************************** Unkown network status");
    }
    
    func isConnectedToNetwork() -> Bool {
        return isClientOnline;
    }
    
    func isConnectedToWiFi() -> Bool {
        return isClientOnline && isClientWiFi;
    }
    
    static func sharedInstance() -> Reachability {
        return Reachability.theSharedInstance;
    }
    
    static func registerListener() {
        sharedInstance().registerListener();
    }
    
    func registerListener() {
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status: AFNetworkReachabilityStatus) -> Void in
            switch status {
            case .notReachable:
                self.isClientConnectionUnknown = false;
                
                if self.isClientOnline {
                    self.isClientOnline = false;
                    self.onOffline();
                }
            case .reachableViaWiFi:
                self.isClientConnectionUnknown = false;
                
                if !self.isClientOnline {
                    self.isClientOnline = true;
                    self.onOnline();
                }
                
                if !self.isClientWiFi {
                    self.isClientWiFi = true;
                    self.onWiFi();
                }
            case .reachableViaWWAN:
                self.isClientConnectionUnknown = false;
                
                if !self.isClientOnline {
                    self.isClientOnline = true;
                    self.onOnline();
                }
                
                if self.isClientWiFi {
                    self.isClientWiFi = false;
                    self.onGSM();
                }
            case .unknown:
                if !self.isClientConnectionUnknown {
                    self.isClientConnectionUnknown = true;
                    self.onUnknownConnectionStatus();
                }
            }
        }
        
        AFNetworkReachabilityManager.shared().startMonitoring();
    }
    
}
