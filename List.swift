//
//  List.swift
//  ListHero
//
//  Created by BJ Griffin on 9/23/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import Foundation
import CoreData

class List: NSManagedObject {

    @NSManaged var category: String
    @NSManaged var isComplete: NSNumber
    @NSManaged var lat: String
    @NSManaged var lon: String
    @NSManaged var name: String
    @NSManaged var objectId: String
    @NSManaged var syncStatus: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var user: String
    @NSManaged var items: NSSet
    
    @NSManaged func addItems(items: NSSet)
}
