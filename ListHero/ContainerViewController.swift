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
//    var checklistViewController : ChecklistViewController
    var forcedTraitCollection : UITraitCollection
    
    init(coder aDecoder: NSCoder!) {
        var delegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.mainSplitViewController = delegate.storyboard.instantiateViewControllerWithIdentifier("MainSplitViewController") as MainSplitViewController
//        self.checklistViewController = delegate.storyboard.instantiateViewControllerWithIdentifier("ChecklistViewController") as ChecklistViewController
        self.forcedTraitCollection = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular)
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.setOverrideTraitCollection(self.forcedTraitCollection, forChildViewController: self.mainSplitViewController)
//        self.mainSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        self.addChildViewController(self.mainSplitViewController)
        self.mainSplitViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection!) {
        if (self.view.bounds.size.width > 320.0) {
            println("traitcollection before -- \(self.mainSplitViewController.traitCollection)")
            self.forcedTraitCollection = UITraitCollection(traitsFromCollections: [UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular)])
            self.setOverrideTraitCollection(self.forcedTraitCollection, forChildViewController: self.mainSplitViewController)
            println("traitcollection after -- \(self.mainSplitViewController.traitCollection)")
            self.mainSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
            self.view.setNeedsLayout()
            println("display mode -- \(self.mainSplitViewController.preferredDisplayMode)")
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
//        if (size.width > 320.0) {
//            self.forcedTraitCollection = UITraitCollection(traitsFromCollections: [UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular)])
//            self.setOverrideTraitCollection(self.forcedTraitCollection, forChildViewController: self.mainSplitViewController)
//            println("traitcollection before -- \(self.mainSplitViewController.traitCollection)")
//        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        //        self.setOverrideTraitCollection(self.forcedTraitCollection, forChildViewController: self.mainSplitViewController)
    }
    
//    override func separateSecondaryViewControllerForSplitViewController(splitViewController: UISplitViewController!) -> UIViewController! {
//    
//    }
}
