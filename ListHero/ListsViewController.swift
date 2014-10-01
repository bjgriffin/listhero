//
//  ListsViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 9/15/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DrawerCellActionDelegate {
    @IBOutlet weak var tableView: UITableView!
    lazy var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    lazy var sortedListItems = NSArray()
    weak var checklistViewController:ChecklistViewController!
    var syncManager:SyncManager!
    var lists:NSMutableArray?
    
    required init(coder aDecoder: NSCoder) {
        syncManager = SyncManager.sharedInstance
        lists = syncManager.fetchLists()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.styleTableView()
        
        var nib = UINib(nibName: "DrawerTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "DrawerTableViewCell")
        
        self.tabBarItem.selectedImage = UIImage(named:"pencil-icon-tab.png")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Helper Methods
    func styleTableView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.tableView.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0);
    }
    
    // MARK: Trait Collection / Size Delegate Methods
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection) {

    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    // MARK: UITableView Datasource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:DrawerTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("DrawerTableViewCell") as DrawerTableViewCell
        cell.delegate = self
        
        if let lsts:NSArray = lists {
            
            var sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
            var descriptors:NSArray = NSArray(objects: sortDescriptor)
            self.sortedListItems = lsts.sortedArrayUsingDescriptors(descriptors)
            
            var list:List = self.sortedListItems.objectAtIndex(indexPath.row) as List
            
            if list.objectID.URIRepresentation().absoluteString == self.checklistViewController.currentList?.objectID.URIRepresentation().absoluteString {
                self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            }
            
            cell.listName.text = list.name
            cell.list = list
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        
        if let lsts:NSArray = lists {
            count = lsts.count
        }
        return count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.checklistViewController.currentList = self.sortedListItems.objectAtIndex(indexPath.row) as? List
        self.checklistViewController.addNavTitles(self.checklistViewController.currentList!.name)
        self.checklistViewController.tableView.reloadData()
        
        if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Compact {
            self.navigationController?.pushViewController(self.checklistViewController, animated: true)
        }
    }
    
    // MARK: DrawerCellActionDelegate Methods
    
    func penButtonSelected(cell: DrawerTableViewCell) {
        var alertController:UIAlertController = UIAlertController(title: "\(cell.listName.text!)", message: "Would you like to change \(cell.listName.text!)'s title?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "new list title"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = alertController.textFields!
            let nameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            cell.list?.name = nameTextField.text
            self.syncManager.coreDataManager.saveMasterContext()
            self.tableView.reloadData()
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }

}
