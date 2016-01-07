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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        Parse.setApplicationId("C5ajjGiFo0SamAC4bin6DHiSO9SQdpove7llmmgg", clientKey: "mo8Su2bCJcvuc1r2sAJ70mqKQormqS2jctfjD2ZI");
        
        //Save currentUser to either anonymous or current user
//        UserManager.updateUser()
        
        dataManager.fetchLists() {
            objects, error in
            if error == nil {
                dataManager.lists = objects
                dataManager.updateCurrentData()
                if let currentListObjectId = NSUserDefaults.standardUserDefaults().objectForKey("currentList") as? String {
                    dataManager.updateCurrentList(currentListObjectId)
                    dataManager.updateCurrentListItems()
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName("listsUpdated", object: nil, userInfo: nil)
        }
        
        dataManager.fetchFavorites() {
            objects, error in
            dataManager.favoriteItems = objects
        }
                
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        if let currentList = dataManager.currentList {
            NSUserDefaults.standardUserDefaults().setObject(currentList.objectID.URIRepresentation().absoluteString, forKey: "currentList")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
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

