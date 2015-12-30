//
//  MainSplitViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/10/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {
     var listsViewController : ListsViewController!
     var checklistViewController : ChecklistViewController!
     var favoritesViewController : FavoritesViewController!

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .AllVisible
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Trait Collection / Size Delegate Methods
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        let shouldBeRegularSizeClass:Bool = self.view.bounds.size.width > 320.0
        let _ = shouldBeRegularSizeClass ? UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular) : UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Compact)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    func primaryViewControllerForCollapsingSplitViewController(splitViewController: UISplitViewController!) -> UIViewController! {
        return self.viewControllers[1]
    }
}
