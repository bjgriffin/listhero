//
//  NSManagedObjectExtension.swift
//  ListHero
//
//  Created by BJ Griffin on 9/29/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import CoreData

extension NSManagedObject {
    func mutableLists() -> NSMutableSet {
        return self.mutableSetValueForKey("lists")
    }
    func mutableItems() -> NSMutableSet {
        return self.mutableSetValueForKey("items")
    }
}
