//
//  ListTableViewCell.swift
//  ListHero
//
//  Created by BJ Griffin on 9/25/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    var item:ListItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateFavorited() {
        self.favoriteImageView.image = UIImage(named: self.item?.isFavorited == true ? "star-icon-favorited.png" : "star-icon-unfavorited.png")
    }
    
    func updateCompleted() {
        self.checkboxImageView.image = UIImage(named: self.item?.isComplete == true ? "complete.png" : "incomplete.png")
    }
    
    func setupCell() {
        self.updateFavorited()
        self.updateCompleted()
        self.checkboxImageView.userInteractionEnabled = true
        self.checkboxImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("toggleCompleted")))
        
        self.favoriteImageView.userInteractionEnabled = true
        self.favoriteImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("toggleFavorited")))
    }
    
    func toggleCompleted() {
        guard let item = item else { return }
        dataManager.updateCompleted(item) {
            error in
            self.updateCompleted()
//            NSNotificationCenter.defaultCenter().postNotificationName("completeUpdated", object: self, userInfo: nil)
        }
    }
    
    func toggleFavorited() {
        guard let item = item else { return }
        dataManager.updateFavorited(item) {
            error in
            self.updateFavorited()
            dataManager.fetchFavorites() {
                objects, error in
                dataManager.favoriteItems = objects
                NSNotificationCenter.defaultCenter().postNotificationName("favoriteUpdated", object: self, userInfo: nil)
            }
        }
    }
}
