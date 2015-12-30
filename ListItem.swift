//
//  ListItem.swift
//  ListHero
//
//  Created by BJ Griffin on 9/23/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import Foundation
import CoreData

class ListItem: NSManagedObject {

    @NSManaged var details: String
    @NSManaged var isComplete: NSNumber
    @NSManaged var isFavorited: NSNumber
    @NSManaged var name: String
    @NSManaged var objectId: String
    @NSManaged var syncStatus: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var lists: NSSet
    
    @NSManaged func addLists(lists: NSSet)
}
