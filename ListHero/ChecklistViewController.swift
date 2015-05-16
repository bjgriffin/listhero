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
    var sortedListItems = Array<ListItem>()
    lazy var coreDataManager = CoreDataManager.sharedInstance
    var defaultCenter = NSNotificationCenter.defaultCenter()
    var dataManager:DataManager!
    var userDefaults:NSUserDefaults!
    var currentList:List?
    
    required init(coder aDecoder: NSCoder)
    {
        dataManager = DataManager.sharedInstance
        currentList = dataManager.currentList
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.objectForKey("lastListURI") != nil {
            for list in dataManager.lists! {
                if list.objectID.URIRepresentation().absoluteString == userDefaults.objectForKey("lastListURI") as? String {
                    currentList = list
                }
            }
        } else {
            if let count = dataManager.lists?.count, lo = dataManager.lists?[count - 1] {
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
        
        if let lo:List = currentList {
            self.addNavTitles(lo.name)
        }
        
        defaultCenter.addObserver(self, selector: "listSelected:", name: "listSelected", object: nil)
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
    
    //MARK: NSNotificationCenter callbacks
    func listSelected(notification:NSNotification) {
        if let currentlist = currentList {
            addNavTitles(currentlist.name)
            tableView.reloadData()
            
            //TODO: Validate push for checklist vc
            if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Compact {
                self.navigationController?.pushViewController(self, animated: true)
            }
        }
    }
    
    func showSignUpAlert() {
        self.presentViewController(UserManager.showLoginAlertController(), animated: true, completion: nil)
    }
    
    func deleteItemsAction() {
        var array = currentList?.items.allObjects as! Array<ListItem>
        
        var alertController:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Completed Items?", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            
            var filteredArray = array.filter({m in m.isComplete == true})
            
            for object:ListItem in filteredArray {
                self.coreDataManager.masterManagedObjectContext?.deleteObject(object as NSManagedObject)
            }
            self.coreDataManager.saveMasterContext()
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Delete All Items?", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            for object:AnyObject in array {
                self.coreDataManager.masterManagedObjectContext?.deleteObject(object as! NSManagedObject)
            }
            self.coreDataManager.saveMasterContext()
            self.tableView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete \(self.currentList?.name)?", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            if var currentlist = self.currentList, lists = self.dataManager.lists, var indexOfCurrentList = find(lists, currentlist) {

                self.coreDataManager.masterManagedObjectContext?.deleteObject(currentlist as NSManagedObject)
                lists.removeAtIndex(indexOfCurrentList)
                self.coreDataManager.saveMasterContext()
                
                if let list = self.dataManager.lists?.last {
                    self.currentList = list
                    self.addNavTitles(self.currentList!.name)
                }
            }
            self.defaultCenter.postNotificationName("listsUpdated", object: nil, userInfo: nil)
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
            let textFields = alertController.textFields ?? []
            let nameTextField = textFields[0] as! UITextField
            let notesTextField = textFields[1] as! UITextField
            
            let itemName = nameTextField.text
            let notes = notesTextField.text
            
            if let currentlist = self.currentList {
                self.dataManager.createItem(itemName, list: currentlist, details: notes)
            }
            
            self.tableView.reloadData()
        }))
        presentViewController(alertController, animated: false, completion: nil)
    }
    
    @IBAction func createListAction(sender: AnyObject) {
        var alertController = UIAlertController(title: "New List", message: "", preferredStyle: UIAlertControllerStyle.Alert)

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
            let textFields = alertController.textFields ?? []
            let nameTextField = textFields[0] as! UITextField
            let categoryTextField = textFields[0] as! UITextField
            
            let name:String = nameTextField.text
            let category:String = categoryTextField.text

            self.dataManager.createList(name, category: category)
            if let list = self.dataManager.lists?.last {
                self.currentList = list
            }

            self.addNavTitles(name)
            self.defaultCenter.postNotificationName("listsUpdated", object: nil, userInfo: nil)
            self.tableView.reloadData()
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
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        var array = [self.navItem.rightBarButtonItem!,UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action:Selector("deleteItemsAction"))]
        
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
        var cell = self.tableView.dequeueReusableCellWithIdentifier("ListTableViewCell") as! ListTableViewCell
        cell.delegate = self
        
        if let cl:List = self.currentList {
            var items = cl.items.allObjects as! Array<ListItem>

            self.sortedListItems = items.sorted({ $0.updatedAt.compare($1.updatedAt) == .OrderedDescending })
            
            var object = self.sortedListItems[indexPath.row] as ListItem
            cell.item = object
            cell.itemName.text = object.name
            cell.setupCell()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
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
