//
//  MainTabBarController.swift
//  ListHero
//
//  Created by BJ Griffin on 9/16/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    @IBOutlet weak var signInOutBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var profileBarButttonItem: UIBarButtonItem!
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var barButtonsArray:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user:PFUser = PFUser.currentUser() {
            self.signedInSetup()
        } else {
            self.signedOutSetup(false)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "signedInNotification:", name:"signedIn", object: nil)
    }
    
    func signedInNotification(notification: NSNotification) {
        self.signedInSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInOutAction(sender: AnyObject) {
        if let title:String! = self.signInOutBarButtonItem.title {
            if title == "Sign In" {
                self.presentViewController(UserManager.showLoginAlertController(), animated: true, completion: nil)
            } else {
                self.signedOutSetup(true)
            }
        }
    }
    
    func signedInSetup() {
        if (self.navigationItem.leftBarButtonItems == nil) {
            if (barButtonsArray.count != 0) {
                self.navigationItem.leftBarButtonItem = barButtonsArray.objectAtIndex(0) as? UIBarButtonItem
            }
        }
        self.signInOutBarButtonItem.title! = "Sign Out"
    }
    
    func signedOutSetup(performLogOut: Bool) {
        if performLogOut {
            userDefaults.setValue("anonymous", forKey: "currentUser")
            PFUser.logOut()
        }
        if !barButtonsArray.containsObject(self.profileBarButttonItem) {
            barButtonsArray.addObject(profileBarButttonItem)
        }
        self.navigationItem.leftBarButtonItems = nil
        self.signInOutBarButtonItem.title! = "Sign In"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
