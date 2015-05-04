//
//  StoryboardExtension.swift
//  ListHero
//
//  Created by Bethurel Griffin on 1/17/15.
//  Copyright (c) 2015 BJ Griffin. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    class func containerViewController() -> ContainerViewController {
        let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("ContainerViewController") as! ContainerViewController
    }
    
    class func mainSplitViewController() -> MainSplitViewController {
        let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("MainSplitViewController") as! MainSplitViewController
    }
    
    class func checklistViewController() -> ChecklistViewController {
        let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("ChecklistViewController") as! ChecklistViewController
    }
    
    class func listsViewController() -> ListsViewController {
        let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("ListsViewController") as! ListsViewController
    }
}
