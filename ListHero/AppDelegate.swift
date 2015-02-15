//
//  AppDelegate.swift
//  ListHero
//
//  Created by BJ Griffin on 7/9/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var syncManager = SyncManager.sharedInstance
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        Parse.setApplicationId("C5ajjGiFo0SamAC4bin6DHiSO9SQdpove7llmmgg", clientKey: "mo8Su2bCJcvuc1r2sAJ70mqKQormqS2jctfjD2ZI");
        
        //Save currentUser to either anonymous or current user
        UserManager.updateUser()
        
//        self.syncManager.sync()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {

//        if let list:List = self.containerViewController!.mainSplitViewController.checklistViewController.currentList {
//            self.defaults.setObject(list.objectID.URIRepresentation().absoluteString, forKey: "lastListURI")
//            self.defaults.synchronize()
//        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

