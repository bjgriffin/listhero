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
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
