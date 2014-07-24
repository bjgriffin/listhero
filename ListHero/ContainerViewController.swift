//
//  ContainerViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/13/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    var mainSplitViewController : MainSplitViewController
    var forcedTraitCollection : UITraitCollection
    
    init(coder aDecoder: NSCoder!) {
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
}
