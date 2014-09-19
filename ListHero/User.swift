//
//  User.swift
//  ListHero
//
//  Created by BJ Griffin on 9/11/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var objectId: String
    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var authData: String
    @NSManaged var emailVerified: NSNumber
    @NSManaged var email: String
    @NSManaged var createdAt: NSDate

}
