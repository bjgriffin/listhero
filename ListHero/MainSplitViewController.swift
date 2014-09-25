//
//  MainSplitViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/10/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection) {
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate
        var shouldBeRegularSizeClass:Bool = self.view.bounds.size.width > 320.0
        var traitCollection:UITraitCollection = shouldBeRegularSizeClass ? UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular) : UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Compact)
        
        delegate.containerViewController!.setOverrideTraitCollection(traitCollection, forChildViewController: self);
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    func primaryViewControllerForCollapsingSplitViewController(splitViewController: UISplitViewController!) -> UIViewController! {
        return self.viewControllers[1] as UIViewController;
    }
}
