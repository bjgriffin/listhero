//
//  DrawerTableViewCell.swift
//  ListHero
//
//  Created by BJ Griffin on 9/25/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

protocol DrawerCellActionDelegate {
    func penButtonSelected(cell: DrawerTableViewCell)
}

class DrawerTableViewCell: UITableViewCell {
    @IBOutlet weak var listName: UILabel!
    @IBOutlet weak var penButton: UIButton!
    var delegate:DrawerCellActionDelegate?
    var list:List?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func penEditAction(sender: AnyObject) {
        self.delegate?.penButtonSelected(self)
    }
}
