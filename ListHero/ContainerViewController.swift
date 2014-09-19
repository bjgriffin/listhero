//
//  ContainerViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/13/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, UISplitViewControllerDelegate {
    var mainSplitViewController : MainSplitViewController
    var forcedTraitCollection : UITraitCollection
    
    required init(coder aDecoder: NSCoder!) {
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.mainSplitViewController = delegate.storyboard.instantiateViewControllerWithIdentifier("MainSplitViewController") as MainSplitViewController
        self.forcedTraitCollection = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular)
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.addChildViewController(self.mainSplitViewController)
        self.mainSplitViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection!) {

    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
    }
    
//    func splitViewController(svc: UISplitViewController!, shouldHideViewController vc: UIViewController!, inOrientation orientation: UIInterfaceOrientation) -> Bool {
//        return false;
//    }
}
