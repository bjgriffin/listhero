//
//  FavoritesViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 9/29/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    lazy var syncManager = SyncManager.sharedInstance
    lazy var sortedFavoriteItems = Array<ListItem>()
    var favoriteItems:Array<ListItem>!
    weak var checklistViewController : ChecklistViewController!
    
    required init(coder aDecoder: NSCoder)
    {
        checklistViewController = UIStoryboard.checklistViewController()
        var items = self.checklistViewController.currentList?.items.allObjects as? Array<ListItem>
        favoriteItems = items?.filter({m in m.isFavorited == true})
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        self.tableView.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0);
        
        var nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "ListTableViewCell")
        
        self.tabBarItem.selectedImage = UIImage(named:"star-icon-favorited.png")
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView Datasource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:FavoriteTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("FavoriteTableViewCell") as FavoriteTableViewCell
        sortedFavoriteItems = favoriteItems.sorted({ $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedAscending })
            
            var item:ListItem = self.sortedFavoriteItems[indexPath.row] as ListItem
            
            if item.objectID.URIRepresentation().absoluteString == self.checklistViewController.currentList?.objectID.URIRepresentation().absoluteString {
                self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            }
            
            cell.itemName.text = item.name
            
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        
        if let items:NSArray = self.favoriteItems {
            count = items.count
        }
        return count
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
