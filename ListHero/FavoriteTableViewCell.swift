//
//  FavoriteTableViewCell.swift
//  ListHero
//
//  Created by BJ Griffin on 9/25/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var itemName: UILabel!
    var item : ListItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addToListAction(sender: AnyObject) {
        if let currentList = dataManager.currentList, item = item {
            dataManager.addItem(currentList, listItem: item, name: item.name, details: item.details) {
                error in
                dataManager.fetchLists() {
                    objects, error in
                    dataManager.lists = objects
                    dataManager.updateCurrentList(currentList.objectID.URIRepresentation().absoluteString)
                    dataManager.updateCurrentListItems()
                    NSNotificationCenter.defaultCenter().postNotificationName("listsUpdated", object: nil, userInfo: nil)
                }
            }
        }
    }
}
