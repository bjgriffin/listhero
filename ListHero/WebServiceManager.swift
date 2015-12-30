//
//  WebServiceManager.swift
//  ListHero
//
//  Created by BJ Griffin on 12/20/15.
//  Copyright © 2015 BJ Griffin. All rights reserved.
//

import UIKit

/*
**Currently using PARSE**
*/
class WebServiceManager {

    //MARK: Create Methods Remote Service
    
    func createListRemote(name:String, category:String, completion:(error:ErrorType?) -> Void) {
        let list = PFObject(className: "List")
        list["user"] = PFUser.currentUser() != nil ? PFUser.currentUser().objectId : "anonymous"
        list["name"] = name
        
        list["createdAt"] = NSDate()
        list["updatedAt"] = NSDate()
        
        list.saveInBackgroundWithBlock({(success:Bool, error:NSError?) -> Void in
            if success {
                completion(error: nil)
            } else {
                if let error = error {
                    completion(error: error)
                }
            }
        })
    }
    
    func createItemRemote(name:String, list:List, details:String, completion:(error:ErrorType?) -> Void) {
        let item = PFObject(className: "ListItem")
        
        item["name"] = name
        item["details"] = details
        item["updatedAt"] = NSDate()
        //TODO: Add Item list
        
        item.saveInBackgroundWithBlock({(success:Bool, error:NSError?) -> Void in
            if success {
                completion(error:nil)
            } else {
                if let error = error {
                    completion(error:error)
                }
            }
        })
    }
    
}
