//
//  ChecklistViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/15/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//
import UIKit
import CoreData

class ChecklistViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.tableView.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0);
    }
    
    override func viewDidAppear(animated: Bool) {
//        var managedObjectContext:NSManagedObjectContext = self.coreDataManager.masterManagedObjectContext!
//        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "User")
//        var objecs:NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)
//        println("\(objecs.objectAtIndex(0))")
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if (userDefaults.objectForKey("signupShown") == nil) {
            self.showSignUpAlert()
            userDefaults.setObject(1, forKey: "signupShown")
            if (PFUser.currentUser().objectId != nil) {
                userDefaults.setObject("\(PFUser.currentUser().objectId)", forKey: "currentUser")
            }
            userDefaults.synchronize()
        }
    }
    
    func showSignUpAlert() {
        self.presentViewController(UserManager.showLoginAlertController(), animated: true, completion: nil)
    }
    
    @IBAction func addItemAction(sender: AnyObject) {
        var alertController:UIAlertController = UIAlertController(title: "New Item", message: "", preferredStyle: UIAlertControllerStyle.Alert)

        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "item name"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = alertController.textFields!
            let textField:UITextField = textFields.objectAtIndex(0) as UITextField
            
            let item:String = textField.text
            //TODO - Add Item Implementation
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    @IBAction func createListAction(sender: AnyObject) {
        var alertController:UIAlertController = UIAlertController(title: "New List", message: "", preferredStyle: UIAlertControllerStyle.Alert)

        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "list name"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = alertController.textFields!
            let textField:UITextField = textFields.objectAtIndex(0) as UITextField
            
            let list:String = textField.text
            //TODO - Add List Implementation
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if (size.width > 320.0) {
            //            self.forcedTraitCollection = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular)
        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        //        self.setOverrideTraitCollection(self.forcedTraitCollection, forChildViewController: self.mainSplitViewController)
    }
}
