//
//  UserManager.swift
//  ListHero
//
//  Created by BJ Griffin on 9/11/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit
import CoreData

class UserManager: NSObject {
    
    class func showLoginAlertController() -> UIAlertController {
        var coreDataManager = CoreDataManager.sharedInstance
        var alertController:UIAlertController = UIAlertController(title: "Sign In/Up", message: "Sign in or register for a new account", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "email"
        })
        
        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "password"
            textField.secureTextEntry = true
        })
        
        alertController.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = alertController.textFields!
            let emailField:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordField:UITextField = textFields.objectAtIndex(0) as UITextField
            
            var managedObjectContext:NSManagedObjectContext = coreDataManager.masterManagedObjectContext!
            
            var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "User")
            var predicate:NSPredicate = NSPredicate(format: "(email = %@) AND (password = %@)", emailField.text, passwordField.text)
            fetchRequest.predicate = predicate
            
            var err: NSError? = nil
            var count:Int = managedObjectContext.countForFetchRequest(fetchRequest, error: &err)
            if (count > 0) {
                var objecs:NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)!
                if let usr:User = objecs.objectAtIndex(0) as? User {
                    UserManager.setCurrentProfileUserDefaults(usr)
                    NSNotificationCenter.defaultCenter().postNotificationName("signedIn", object: nil)
                }
            }
            
            PFUser.logInWithUsernameInBackground(emailField.text, password: passwordField.text) {
                (user:PFUser!, error:NSError!) -> Void in
                if((user) != nil) {
                } else {
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Register", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = alertController.textFields!
            let emailField:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordField:UITextField = textFields.objectAtIndex(0) as UITextField
            
            var user:PFUser = PFUser()
            user.username = emailField.text
            user.email = emailField.text
            user.password = passwordField.text
            user.signUpInBackgroundWithBlock{
                (success:Bool!, error:NSError!)->Void in
                if let erfin = error {
                    println("Error: \(error)")
                } else {
                    var managedObjectContext:NSManagedObjectContext = coreDataManager.masterManagedObjectContext!
                    
                    var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "User")
                    var predicate:NSPredicate = NSPredicate(format: "email = %@", emailField.text)
                    fetchRequest.predicate = predicate
                    
                    var err: NSError? = nil
                    var count:Int = managedObjectContext.countForFetchRequest(fetchRequest, error: &err)
                    if (count == 0) {
                        managedObjectContext.performBlockAndWait({
                            var cdUser:User = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: managedObjectContext) as User
                            cdUser.objectId = user.objectId
                            cdUser.username = user.username
                            cdUser.password = user.password
                            cdUser.email = user.email
                            coreDataManager.saveMasterContext()
                            UserManager.setCurrentProfileUserDefaults(cdUser)
                            NSNotificationCenter.defaultCenter().postNotificationName("signedIn", object: nil)
                        })
                    }
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        return alertController
    }
    
    class func setCurrentProfileUserDefaults(user:User) {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("\(user.objectId)", forKey: "currentUser")
        userDefaults.setObject("\(user.email)", forKey: "currentEmail")
    }
}
