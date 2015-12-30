//
//  CoreDataManager.swift
//  ListHero
//
//  Created by BJ Griffin on 9/10/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager:NSObject {
    
    //MARK: Fetch Methods Core Data
    
    func fetchLists(completion:(objects:[List]?, error:ErrorType?) -> Void) {
        let fetchRequest = NSFetchRequest(entityName: kEntityName.entityList.rawValue)
        fetchRequest.fetchBatchSize = 50
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    
        var data : [List]?
        
        do {
            data = try masterManagedObjectContext.executeFetchRequest(fetchRequest) as? [List]
        } catch let error {
            completion(objects: nil, error: error)
            return
        }
        
        completion(objects: data, error: nil)
    }
    
    func fetchFavorites(completion:(objects:[ListItem]?, error:ErrorType?) -> Void) {
        let fetchRequest = NSFetchRequest(entityName: kEntityName.entityItem.rawValue)
        
        let predicate = NSPredicate(format: "isFavorited == 1")
        fetchRequest.predicate = predicate
        
        var data : [ListItem]?
        
        do {
            data = try masterManagedObjectContext.executeFetchRequest(fetchRequest) as? [ListItem]
        } catch let error {
            completion(objects: nil, error: error)
            return
        }
        
        completion(objects: data, error: nil)
    }
    
    //MARK: Update Methods Core Data
    
    func updateListName(list:List, name:String, completion:(error:ErrorType?) -> Void) {
        list.name = name
        list.updatedAt = NSDate()
        
        saveContext() {
            error in
            completion(error: error)
        }
    }
    
    func updateFavorited(item:ListItem, completion:(error:ErrorType?) -> Void) {
        if item.isFavorited == true {
            item.isFavorited = false
        } else {
            item.isFavorited = true
        }
        item.updatedAt = NSDate()
        
        saveContext() {
            error in
            completion(error: error)
        }
    }
    
    func updateCompleted(item:ListItem, completion:(error:ErrorType?) -> Void) {
        if item.isComplete == true {
            item.isComplete = false
        } else {
            item.isComplete = true
        }
        item.updatedAt = NSDate()
        
        saveContext() {
            error in
            completion(error: error)
        }
    }
    
    //MARK: Create Methods Core Data
    
    func createList(name:String, category:String, completion:(error:ErrorType?) -> Void) {
        let list = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityList.rawValue, inManagedObjectContext: masterManagedObjectContext) as? List
        
        list?.user = PFUser.currentUser() != nil ? PFUser.currentUser().objectId : "anonymous"
        list?.name = name
        list?.category = category
        list?.createdAt = NSDate()
        list?.updatedAt = NSDate()
        
        saveContext() {
            error in
            completion(error: error)
        }
    }
    
    func createItem(name:String, list:List, details:String, completion:(error:ErrorType?) -> Void) {
        let item = NSEntityDescription.insertNewObjectForEntityForName(kEntityName.entityItem.rawValue, inManagedObjectContext: masterManagedObjectContext) as? ListItem
        
        item?.name = name
        item?.details = details
        item?.createdAt = NSDate()
        item?.updatedAt = NSDate()
        item?.addLists(NSSet(array: [list]))
        
        saveContext() {
            error in
            completion(error: error)
        }
    }
    
    //MARK: Create Methods Core Data

    func deleteItem(item:ListItem, completion:(error:ErrorType?) -> Void) {
        masterManagedObjectContext.deleteObject(item)
        saveContext() {
            error in
            completion(error: error)
        }
    }
    
    func deleteList(list:List, completion:(error:ErrorType?) -> Void) {
        masterManagedObjectContext.deleteObject(list)
        saveContext() {
            error in
            completion(error: error)
        }
    }
    
    // MARK: Default Core Data Methods
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "test.test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ListHero", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ListHero.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var masterManagedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext (completion:(error:ErrorType?) -> Void) {
        if masterManagedObjectContext.hasChanges {
            do {
                try masterManagedObjectContext.save()
            } catch let error {
                completion(error:error)
            }
        }
        completion(error:nil)
    }

}