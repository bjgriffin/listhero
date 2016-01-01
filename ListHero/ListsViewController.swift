//
//  ListsViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 9/15/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit
import CoreData

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DrawerCellActionDelegate {
    @IBOutlet weak var tableView: UITableView!
    var setSelectedList = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("listsUpdated"), name: "listsUpdated", object: nil)
        
        
        let nib = UINib(nibName: "DrawerTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "DrawerTableViewCell")
        
        tabBarItem.selectedImage = UIImage(named:"pencil-icon-tab.png")
        setSelectedList = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: NSNotificationCenter callbacks
    func listsUpdated() {
        tableView.reloadData()
        guard let currentList = dataManager.currentList, let index = dataManager.lists?.indexOf(currentList) else { return }
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
    }
    
    // MARK: UITableView Datasource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DrawerTableViewCell") as! DrawerTableViewCell
        cell.delegate = self
        
        if let list = dataManager.lists?[indexPath.row] {
            cell.listName.text = list.name
            cell.list = list
            if setSelectedList && (list.objectID == dataManager.currentList?.objectID) {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                setSelectedList = false
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.lists?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dataManager.currentList = dataManager.lists?[indexPath.row]
        dataManager.updateCurrentListItems()
        NSNotificationCenter.defaultCenter().postNotificationName("listSelected", object: nil, userInfo: nil)
    }
    
    // MARK: DrawerCellActionDelegate Methods
    
    func penButtonSelected(cell: DrawerTableViewCell) {
        let listName = cell.listName.text ?? ""
        let alertController = UIAlertController(title: "\(listName)", message: "Would you like to change \(listName)'s title?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "new title"
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields = alertController.textFields ?? []
            let nameTextField:UITextField = textFields[0]
            
            if let list = cell.list, name = nameTextField.text {
                dataManager.updateItemName(list, name: name) {
                    error in
                    if let currentList = dataManager.currentList {
                        dataManager.fetchLists() {
                            objects, error in
                            dataManager.lists = objects
                            dataManager.updateCurrentList(currentList.objectID.URIRepresentation().absoluteString)
                            dataManager.updateCurrentListItems()
                            alertController.dismissViewControllerAnimated(true, completion: nil)
                            NSNotificationCenter.defaultCenter().postNotificationName("listsUpdated", object: nil, userInfo: nil)
                        }
                    }
                }
            }
        }))
        self.presentViewController(alertController, animated: false, completion: nil)
    }

}
