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
//        var coreDataManager = CoreDataManager.sharedInstance
        let alertController:UIAlertController = UIAlertController(title: "Sign In/Up", message: "Sign in or register for a new account", preferredStyle: UIAlertControllerStyle.Alert)
        
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
            let textFields = alertController.textFields ?? []
            let emailField = textFields[0]
            let passwordField = textFields[1]
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

            PFUser.logInWithUsernameInBackground(emailField.text, password: passwordField.text) {
                (user:PFUser!, error:NSError!) -> Void in
                if(error != nil) {
                    print(error)
                    userDefaults.setValue("anonymous", forKey: "currentUser")
                } else {
                    userDefaults.setValue(user.objectId, forKey: "currentUser")
                    NSNotificationCenter.defaultCenter().postNotificationName("signedIn", object: nil)
                }
                userDefaults.synchronize()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Register", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields = alertController.textFields ?? []
            let emailField:UITextField = textFields[0] 
            let passwordField:UITextField = textFields[1] 

            let user:PFUser = PFUser()
            user.username = emailField.text
            user.email = emailField.text
            user.password = passwordField.text
            
//            user.signUpInBackgroundWithBlock {
//                (success:Bool!, error:NSError!) -> Void in
//                if error != nil {
//                    println(error)
//                    userDefaults.setValue("anonymous", forKey: "currentUser")
//                } else {
//                    userDefaults.setValue(user.objectId, forKey: "currentUser")
//                    NSNotificationCenter.defaultCenter().postNotificationName("signedIn", object: nil)
//                }
//                userDefaults.synchronize()
//            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        return alertController
    }
    
    class func updateUser() {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let user:PFUser = PFUser.currentUser() {
            userDefaults.setObject("\(user.objectId)", forKey: "currentUser")
        } else {
            userDefaults.setObject("anonymous", forKey: "currentUser")
        }
        userDefaults.synchronize()
    }
    
//    class func setCurrentProfileUserDefaults(user:User) {
//        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        userDefaults.setObject("\(user.objectId)", forKey: "currentUser")
//        userDefaults.setObject("\(user.email)", forKey: "currentEmail")
//    }
}
