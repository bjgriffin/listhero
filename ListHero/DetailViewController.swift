//
//  DetailViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 1/3/16.
//  Copyright © 2016 BJ Griffin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailTextView : UITextView!
    var item : ListItem?

    override func viewWillAppear(animated: Bool) {
        title = item?.name
        detailTextView.text = item?.details
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let item = item {
            dataManager.updateItemDetail(item, detail: detailTextView.text) {
                error in
            }
        }
        super.viewWillDisappear(animated)
    }
}
