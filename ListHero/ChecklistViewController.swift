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
    @IBOutlet weak var navItem: UINavigationItem!
    lazy var currentList = List()
    lazy var coreDataManager = CoreDataManager.sharedInstance
    lazy var syncManager = SyncManager.sharedInstance

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
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if (userDefaults.objectForKey("signupShown") == nil) {
            self.showSignUpAlert()
            userDefaults.setObject(1, forKey: "signupShown")
            if let user:PFUser = PFUser.currentUser() {
                userDefaults.setObject("\(user.objectId)", forKey: "currentUser")
            } else {
                userDefaults.setObject("anonymous", forKey: "currentUser")
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
        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "notes (optional)"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = alertController.textFields!
            let nameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            let notesTextField:UITextField = textFields.objectAtIndex(1) as UITextField
            
            let itemName:String = nameTextField.text
            let notes:String = notesTextField.text
            self.currentList = self.syncManager.fetchLists().lastObject as List
            
            self.syncManager.createItem(itemName, list: self.currentList, details: notes)
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    @IBAction func createListAction(sender: AnyObject) {
        var alertController:UIAlertController = UIAlertController(title: "New List", message: "", preferredStyle: UIAlertControllerStyle.Alert)

        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "list name"
        })
        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "category (optional)"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = alertController.textFields!
            let nameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            let categoryTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            
            let name:String = nameTextField.text
            let category:String = categoryTextField.text

            self.syncManager.createList(name, category: category)
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection) {
        var array:NSArray = [self.navItem.rightBarButtonItem!,UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: nil, action:nil)]
        
        if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Compact {
            self.navigationItem.setRightBarButtonItems(array, animated: false)
        } else {
            self.navItem.setRightBarButtonItems(array, animated: false)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if (size.width > 320.0) {
        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
}
