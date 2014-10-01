//
//  ChecklistViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/15/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//
import UIKit
import CoreData

class ChecklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellActionDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    weak var listsViewController:ListsViewController!
    lazy var sortedListItems = NSArray()
    lazy var coreDataManager = CoreDataManager.sharedInstance
    var syncManager:SyncManager!
    var userDefaults:NSUserDefaults!
    var currentList:List?
    
    required init(coder aDecoder: NSCoder)
    {
        syncManager = SyncManager.sharedInstance
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.objectForKey("lastListURI") != nil {
            for list in syncManager.fetchLists() {
                if list.objectID.URIRepresentation().absoluteString == userDefaults.objectForKey("lastListURI") as? String {
                    currentList = list as? List
                }
            }
        } else {
            if let lo:List = syncManager.fetchLists().lastObject as? List {
                currentList = lo
            }
        }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UserManager.updateUser()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.tableView.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0);
        self.tableView.allowsSelection = false
        
        var nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "ListTableViewCell")
        
        if let lo:List = self.currentList {
            self.addNavTitles(lo.name)
        }
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidAppear(animated: Bool) {
        if (self.userDefaults.objectForKey("signupShown") == nil) {
            self.showSignUpAlert()
            self.userDefaults.setObject(1, forKey: "signupShown")
            self.userDefaults.synchronize()
        }
    }
    
    func showSignUpAlert() {
        self.presentViewController(UserManager.showLoginAlertController(), animated: true, completion: nil)
    }
    
    func deleteItemsAction() {
        var array:NSArray? = self.currentList?.items.allObjects as NSArray?
        
        var alertController:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Completed Items?", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            var filteredArray:NSArray? = array?.filteredArrayUsingPredicate(NSPredicate(format: "isComplete == %@", true))
            
            for object:AnyObject in filteredArray! {
                self.coreDataManager.masterManagedObjectContext?.deleteObject(object as NSManagedObject)
            }
            self.coreDataManager.saveMasterContext()
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Delete All Items?", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            for object:AnyObject in array! {
                self.coreDataManager.masterManagedObjectContext?.deleteObject(object as NSManagedObject)
            }
            self.coreDataManager.saveMasterContext()
            self.tableView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
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
            
            self.syncManager.createItem(itemName, list: self.currentList!, details: notes)
            
            //TODO: Remove reloadData code below and add KVO
            self.tableView.reloadData()
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
            if let lo:List = self.syncManager.fetchLists().lastObject as? List {
                self.currentList = lo
            }
            //TODO: Remove code below and add KVO
            self.addNavTitles(name)
            self.tableView.reloadData()
            self.listsViewController.lists = self.syncManager.fetchLists()
            self.listsViewController.tableView.reloadData()
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNavTitles(name: String) {
        self.navigationItem.title = name
        self.navItem.title = name
    }
    
    // MARK: Trait Collection / Size Delegate Methods
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection) {
        var array:NSArray = [self.navItem.rightBarButtonItem!,UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action:Selector("deleteItemsAction"))]
        
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
    
    // MARK: UITableView Datasource Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ListTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ListTableViewCell") as ListTableViewCell
        cell.delegate = self
        
        if let cl:List = self.currentList {

            var items:NSArray = cl.items.allObjects as NSArray

            var sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
            var descriptors:NSArray = NSArray(objects: sortDescriptor)
            self.sortedListItems = items.sortedArrayUsingDescriptors(descriptors)
            
            var object:ListItem = self.sortedListItems.objectAtIndex(indexPath.row) as ListItem
            cell.item = object
            cell.itemName.text = object.name
            cell.setupCell()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        
        if let cl:List = self.currentList {
            count = cl.items.count
        }
        return count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: UITableView Delegate Methods
    func cellFavoriteChanged(cell: ListTableViewCell) {
        println("\(cell.item?.isFavorited)")
    }
    
    func cellCompleteChanged(cell: ListTableViewCell) {
        println("\(cell.item?.isComplete)")
    }
}
