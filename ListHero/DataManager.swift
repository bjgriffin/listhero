//
//  DataManager.swift
//  ListHero
//
//  Created by BJ Griffin on 9/19/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit
import CoreData

enum kEntityName: String {
    case entityList = "List", entityItem = "ListItem"
}

let dataManager = DataManager.sharedInstance

class DataManager: NSObject {
    let coreDataManager = CoreDataManager()
    let webServiceManager = WebServiceManager()
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var lists : [List]?
    var favoriteItems : [ListItem]?
    var currentList : List?
    var currentListItems : [ListItem]?

    class var sharedInstance : DataManager {
        struct Static {
            static let instance = DataManager()
        }
        return Static.instance
    }
    
    //MARK: Fetch Methods
    
    func fetchLists(completion:(objects:[List]?, error:ErrorType?) -> Void) {
        coreDataManager.fetchLists() {
            objects, error in
            //TODO: Handle Error
            completion(objects: objects, error: error)
        }
    }
    
    func fetchFavorites(completion:(objects:[ListItem]?, error:ErrorType?) -> Void) {
        coreDataManager.fetchFavorites() {
            objects, error in
            //TODO: Handle Error
            completion(objects: objects, error: error)
        }
    }
    
    //MARK: Update Methods
    
    func updateCurrentData() {
        updateCurrentList()
        updateCurrentListItems()
    }

    func updateCurrentList() {
        currentList = lists?.first
    }
    
    func updateCurrentList(id:String) {
        let array = lists?.filter { $0.objectID.URIRepresentation().absoluteString == id }
        currentList = array?.first
    }
    
    func updateCurrentListItems() {
        currentListItems = (currentList?.items.allObjects as? [ListItem])?.sort { $0.createdAt.compare($1.createdAt) == .OrderedAscending }
    }
    
    func updateFavorited(item:ListItem, completion:(error:ErrorType?) -> Void) {
        coreDataManager.updateFavorited(item) {
            error in
            completion(error:error)
        }
    }
    
    func updateCompleted(item:ListItem, completion:(error:ErrorType?) -> Void) {
        coreDataManager.updateCompleted(item) {
            error in
            completion(error:error)
        }
    }
    
    func updateListName(list:List, name:String, completion:(error:ErrorType?) -> Void) {
        coreDataManager.updateListName(list, name: name) {
            error in
            completion(error:error)
        }
    }
    
    func updateItemDetail(item:ListItem, detail:String, completion:(error:ErrorType?) -> Void) {
        coreDataManager.updateItemDetail(item, detail: detail) {
            error in
            completion(error:error)
        }
    }
    
    //MARK: Add Methods

    func addItem(list:List, listItem:ListItem, name:String, details:String, completion:(error:ErrorType?) -> Void) {
        if PFUser.currentUser() != nil {
        //    webServiceManager.createItemRemote(name, list: list, details: details) {
        //        error in
        //        self.coreDataManager.createItem(name, list: list, details: details) {
        //            error in
        //            completion(error:error)
        //    }
        //    }
        } else {
            coreDataManager.addItem(list, listItem: listItem, name: name, details: details) {
                error in
                completion(error:error)
            }
        }
        
    }
    
    //MARK: Create Methods
    
    func createList(name:String, category:String, completion:(error:ErrorType?) -> Void) {
        if PFUser.currentUser() != nil {
            webServiceManager.createListRemote(name, category: category) {
                error in
                self.coreDataManager.createList(name, category: category) {
                    error in
                    completion(error:error)
                }
            }
        } else {
            coreDataManager.createList(name, category: category) {
                error in
                completion(error:error)
            }
        }
        
    }
    
    func createItem(name:String, list:List, details:String, completion:(error:ErrorType?) -> Void) {
        if PFUser.currentUser() != nil {
            webServiceManager.createItemRemote(name, list: list, details: details) {
                error in
                self.coreDataManager.createItem(name, list: list, details: details) {
                    error in
                    completion(error:error)
                }
            }
        } else {
            coreDataManager.createItem(name, list: list, details: details) {
                error in
                completion(error:error)
            }
        }
        
    }
    
    //MARK: Delete Methods

    func deleteItem(item:ListItem, completion:(error:ErrorType?) -> Void) {
        coreDataManager.deleteItem(item) {
            error in
            completion(error:error)
        }
    }
    
    func deleteList(list:List, completion:(error:ErrorType?) -> Void) {
        coreDataManager.deleteList(list) {
            error in
            completion(error:error)
        }
    }
    
}
