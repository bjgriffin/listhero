//
//  ChecklistViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/15/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//
import UIKit
import CoreData

class ChecklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    var popoverViewController : UIViewController?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        updateTitleToMatchCurrentList()
        
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ListTableViewCell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "listSelected:", name: "listSelected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "listsUpdated", name: "listsUpdated", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateEnabledButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        if dataManager.currentList == nil {
            showPopover()
        }
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
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    navigationItem.title = dataManager.currentList?.name
                    navigationItem.titleView = nil
                } else {
                    navigationItem.title = nil
                    navigationItem.titleView = nil
                }
            } else {
                splitViewContainerController?.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .Compact), forChildViewController: splitViewController)
                if dataManager.currentList == nil {
                    showLogoTitleView()
                    showPopover()
                } else {
                    navigationItem.titleView = nil
                    navigationItem.title = dataManager.currentList?.name
                }
            }
    }
    
    @IBAction func deleteItemsAction(sender:UIBarButtonItem) {
        let items = dataManager.currentList?.items.allObjects as? [ListItem]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if items?.count > 0 {
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
        }
        
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
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = trashBarButtonItem
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addItemAction(sender: AnyObject) {
        let alertController = UIAlertController(title: "New Item", message: "", preferredStyle: UIAlertControllerStyle.Alert)

        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "item name"
        })
        
        alertController.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "notes"
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
            
            do {
                try itemName.validate()
            } catch let error as ValidateStringError {
                switch error {
                case .AlphanumericOnly:
                    return
                case .AtLeastThreeCharacters:
                    return
                }
            } catch {
                return
            }
            
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
            textField.placeholder = "name"
        })
        
        //TODO: Un-comment for v2.0
//        alertController.addTextFieldWithConfigurationHandler({
//            textField in
//            textField.placeholder = "category"
//        })
        
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
            
            do {
                try name.validate()
            } catch let error as ValidateStringError {
                switch error {
                case .AlphanumericOnly:
                    UIAlertController.showAlert("Error", message: "No special characters allowed in title", cancelButtonTitle: "OK", cancelButtonCompletion: nil)
                    return
                case .AtLeastThreeCharacters:
                    UIAlertController.showAlert("Error", message: "Show at least three character", cancelButtonTitle: "OK", cancelButtonCompletion: nil)
                    return
                }
            } catch {
                UIAlertController.showAlert("Error", message: "Unknown", cancelButtonTitle: "OK", cancelButtonCompletion: nil)
                return
            }

            dataManager.createList(name, category: category) {
                error in
                if error == nil {
                    self.fetchUpdatedLists(true)
                    self.updateEnabledButtons()
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
        guard let currentList = dataManager.currentList else {
            navigationItem.title = nil
            showLogoTitleView()
            return
        }
        
        navigationItem.title = currentList.name
        navigationItem.titleView = nil
    }
    
    //MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverSegue" {
            popoverViewController = segue.destinationViewController
            popoverViewController?.modalPresentationStyle = .Popover
            popoverViewController?.popoverPresentationController?.delegate = self
            popoverViewController?.popoverPresentationController?.backgroundColor = UIColor(red: 0/225.0, green: 51/225.0, blue: 102/225.0, alpha: 0.5)
        } else if segue.identifier == "detail" {
            if let indexPath = sender as? NSIndexPath {
                let item = dataManager.currentListItems?[indexPath.row]
                if let controller = segue.destinationViewController as? DetailViewController {
                    controller.item = item
                }
            }

        }
    }
    
    //MARK: UIPopoverPresentationController Delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
        if !(splitViewController?.traitCollection.horizontalSizeClass == .Regular && UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            updateTitleToMatchCurrentList()
        }
        updateEnabledButtons()
    }
    
    func dismissPopover() {
        popoverViewController?.dismissViewControllerAnimated(true, completion: nil)
        popoverViewController = nil
    }
    
    // MARK: Private Methods
    
    private func showPopover() {
        performSegueWithIdentifier("popoverSegue", sender: nil)
       let _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("dismissPopover"), userInfo: nil, repeats: false)
    }
    
    private func updateEnabledButtons() {
        if dataManager.currentList == nil {
            trashBarButtonItem.enabled = false
            addBarButtonItem.enabled = false
        } else {
            trashBarButtonItem.enabled = true
            addBarButtonItem.enabled = true
        }
    }
    
    private func showLogoTitleView() {
        let titleView = UIImageView(frame:CGRectMake(0, 0, 150, 50))
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("detail", sender: indexPath)
    }
    
}
