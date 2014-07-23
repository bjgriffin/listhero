//
//  ChecklistViewController.swift
//  ListHero
//
//  Created by BJ Griffin on 7/15/14.
//  Copyright (c) 2014 BJ Griffin. All rights reserved.
//

import UIKit

class ChecklistViewController: UIViewController {

    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        if (size.width > 320.0) {
            //            self.forcedTraitCollection = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular)
        }
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        //        self.setOverrideTraitCollection(self.forcedTraitCollection, forChildViewController: self.mainSplitViewController)
    }
}
