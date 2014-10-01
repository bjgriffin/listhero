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
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate

    required init(coder aDecoder: NSCoder) {
        self.mainSplitViewController = self.delegate.storyboard.instantiateViewControllerWithIdentifier("MainSplitViewController") as MainSplitViewController
        
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
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection) {

    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    }
}
