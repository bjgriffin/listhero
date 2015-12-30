//
//  FavoritesViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 9/29/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        let nib = UINib(nibName: "FavoriteTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FavoriteTableViewCell")
        self.tabBarItem.selectedImage = UIImage(named:"star-icon-favorited.png")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "favoriteUpdated:", name: "favoriteUpdated", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "completeUpdated:", name: "completeUpdated", object: nil)
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: NSNotificationCenter callbacks
    
    func favoriteUpdated(notification:NSNotification) {
        tableView.reloadData()
    }
    
    // MARK: UITableView Datasource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FavoriteTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("FavoriteTableViewCell") as! FavoriteTableViewCell
        
        if let item = dataManager.favoriteItems?[indexPath.row] {
            cell.itemName.text = item.name
            if item.objectID.URIRepresentation().absoluteString == dataManager.currentList?.objectID.URIRepresentation().absoluteString {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.favoriteItems?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableView Delegate Methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Compact {
            self.navigationController?.popToRootViewControllerAnimated(false)
        }
    }
}
