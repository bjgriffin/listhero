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
    lazy var sortedLists = Array<List>()
    weak var checklistViewController : ChecklistViewController!
    var syncManager:SyncManager!
    var lists:Array<List>!
    
    required init(coder aDecoder: NSCoder) {
        syncManager = SyncManager.sharedInstance
        lists = syncManager.lists
        checklistViewController = UIStoryboard.checklistViewController()
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
    
    // MARK: UITableView Datasource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("DrawerTableViewCell") as! DrawerTableViewCell
        cell.delegate = self
        
        sortedLists = lists.sorted({ $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending })
        var list = self.sortedLists[indexPath.row] as List
        
        if list.objectID.URIRepresentation().absoluteString == self.checklistViewController.currentList?.objectID.URIRepresentation().absoluteString {
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
        
        cell.listName.text = list.name
        cell.list = list
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.checklistViewController.currentList = self.sortedLists[indexPath.row]
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
            let textFields = alertController.textFields ?? []
            let nameTextField:UITextField = textFields[0] as! UITextField
            cell.list?.name = nameTextField.text
            self.syncManager.coreDataManager.saveMasterContext()
            self.tableView.reloadData()
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }

}
