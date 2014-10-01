//
//  ListTableViewCell.swift
//  ListHero
//
//  Created by BJ Griffin on 9/25/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

protocol CellActionDelegate {
    func cellFavoriteChanged(cell:ListTableViewCell)
    func cellCompleteChanged(cell:ListTableViewCell)
}

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    lazy var coreDataManager = CoreDataManager.sharedInstance
    var delegate:CellActionDelegate?
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
        if self.item?.isComplete == true {
            self.item?.isComplete = false
        } else {
            self.item?.isComplete = true
        }
        self.coreDataManager.saveMasterContext()
        self.updateCompleted()
        
        self.delegate?.cellCompleteChanged(self)
    }
    
    func toggleFavorited() {
        if self.item?.isFavorited == true {
            self.item?.isFavorited = false
        } else {
            self.item?.isFavorited = true
        }
        self.coreDataManager.saveMasterContext()
        self.updateFavorited()
        
        self.delegate?.cellFavoriteChanged(self)
    }
}
