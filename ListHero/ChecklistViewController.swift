//
//  ChecklistViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/15/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//
import UIKit
import CoreData

class ChecklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        tableView.allowsSelection = false
        
        updateTitleToMatchCurrentList()
        
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ListTableViewCell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "listSelected:", name: "listSelected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "listsUpdated", name: "listsUpdated", object: nil)
    }
    
    func showSignUpAlert() {
        self.presentViewController(UserManager.showLoginAlertController(), animated: true, completion: nil)
    }
    
    @IBAction func drawerAction(sender: AnyObject) {
        guard let splitViewController = self.splitViewController else { return }
            let splitViewContainerController = splitViewController.parentViewController
            
            if splitViewController.traitCollection.horizontalSizeClass == .Compact {
                splitViewContainerController?.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .Regular), forChildViewController: splitViewController)
                splitViewController.preferredPrimaryColumnWidthFraction = 0.5
                splitViewController.preferredDisplayMode = .AllVisible
                navigationItem.title = ""
            } else {
                splitViewContainerController?.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .Compact), forChildViewController: splitViewController)
                navigationItem.title = dataManager.currentList?.name
            }
    }
    
    @IBAction func deleteItemsAction(sender:UIBarButtonItem) {
        let items = dataManager.currentList?.items.allObjects as? [ListItem]
        
        let alertController:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Completed Items?", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            
            if let filteredArray = items?.filter({item in item.isComplete == true}) {
                for item in filteredArray {
                    dataManager.deleteItem(item) {
                        error in
                        self.fetchUpdatedLists(false)
                    }
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete All Items?", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            if let items = items {
                for item in items {
                    dataManager.deleteItem(item) {
                        error in
                        self.fetchUpdatedLists(false)
                    }
                }
            }
        }))
        
        if let currentList = dataManager.currentList {
            alertController.addAction(UIAlertAction(title: "Delete \(currentList.name)?", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                dataManager.deleteList(currentList) {
                    error in
                    self.fetchUpdatedLists(true)
                }
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            alertAction in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addItemAction(sender: AnyObject) {
        let alertController:UIAlertController = UIAlertController(title: "New Item", message: "", preferredStyle: UIAlertControllerStyle.Alert)

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
            let nameTextField = textFields[0]
            let notesTextField = textFields[1]
            
            let itemName = nameTextField.text ?? ""
            let notes = notesTextField.text ?? ""
            
            if let currentList = dataManager.currentList {
                dataManager.createItem(itemName, list: currentList, details: notes) {
                    error in
                    self.fetchUpdatedLists(false)
                }
            }
            
        }))
        
        presentViewController(alertController, animated: false, completion: nil)
    }
    
    @IBAction func createListAction(sender: AnyObject) {
        let alertController = UIAlertController(title: "New List", message: "", preferredStyle: UIAlertControllerStyle.Alert)

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
            let nameTextField = textFields[0]
            let categoryTextField = textFields[0]
            
            let name = nameTextField.text ?? ""
            let category = categoryTextField.text ?? ""

            dataManager.createList(name, category: category) {
                error in
                if error == nil {
                    self.fetchUpdatedLists(true)
                }
            }
        }))
        
        presentViewController(alertController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTitleToMatchCurrentList() {
        guard let currentList = dataManager.currentList else { return }
            navigationItem.title = currentList.name
    }
    
    //MARK: NSNotificationCenter callbacks
    
    func listSelected(notification:NSNotification) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            updateTitleToMatchCurrentList()
        }
        tableView.reloadData()
    }
    
    func listsUpdated() {
        tableView.reloadData()
    }
    
    
    // MARK: Private Methods
    
    private func showLogoTitleView() {
        let titleView = UIImageView(frame:CGRectMake(0, 0, 35, 35))
        titleView.contentMode = .ScaleAspectFit
        titleView.image = UIImage(named: "ListHeroLogo")
        navigationItem.titleView = titleView
    }
    
    private func fetchUpdatedLists(shouldUpdateCurrentList:Bool) {
        dataManager.fetchLists() {
            objects, error in
            dataManager.lists = objects
            
            if shouldUpdateCurrentList {
                dataManager.updateCurrentData()
                self.updateTitleToMatchCurrentList()
            } else {
                dataManager.updateCurrentListItems()
            }
            NSNotificationCenter.defaultCenter().postNotificationName("listsUpdated", object: nil, userInfo: nil)
        }
    }
    
    // MARK: Trait Collection / Size Delegate Methods
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if (size.width > 320.0) {
        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    // MARK: UITableView Datasource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ListTableViewCell") as! ListTableViewCell

        let item = dataManager.currentListItems?[indexPath.row]
        cell.item = item
        cell.itemName.text = item?.name
        cell.setupCell()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.currentListItems?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}
