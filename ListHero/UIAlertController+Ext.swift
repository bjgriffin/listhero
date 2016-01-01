//
//  UIAlertController+Ext.swift
//  ListHero
//
//  Created by BJ Griffin on 12/31/15.
//  Copyright © 2015 BJ Griffin. All rights reserved.
//

import UIKit

/**
 UIAlertController extension contains quick methods to show simple alert types
 
 */
extension UIAlertController {
    
    private class func getVisibleViewController() -> UIViewController? {
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        var visibleViewController : UIViewController?
        
        if rootViewController?.presentedViewController == nil {
            if rootViewController is UINavigationController {
                visibleViewController = (rootViewController as! UINavigationController).viewControllers.last
            } else {
                visibleViewController = rootViewController
            }
        } else {
            visibleViewController = rootViewController?.presentedViewController
        }
        
        if object_getClassName(visibleViewController) == object_getClassName(UIAlertController) {
            return nil
        } else {
            return visibleViewController
        }
    }
    
    class func getAlert(title:String?, message:String?, cancelButtonTitle:String?, cancelButtonCompletion:((action:UIAlertAction)->())?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: cancelButtonCompletion)
        alert.addAction(cancelAction)
        return alert
    }
    
    class func getAlert(title:String?, message:String?, cancelButtonTitle:String?, cancelButtonCompletion:((action:UIAlertAction)->())?, actionButtonTitle:String?, actionButtonCompletion:((action:UIAlertAction)->())?) -> UIAlertController {
        let alert = getAlert(title, message: message, cancelButtonTitle: cancelButtonTitle, cancelButtonCompletion:cancelButtonCompletion)
        let action = UIAlertAction(title: actionButtonTitle, style: .Default, handler: actionButtonCompletion)
        alert.addAction(action)
        return alert
    }
    
    class func showAlert(title:String?, message:String?, cancelButtonTitle:String?, cancelButtonCompletion:((action:UIAlertAction)->())?) {
        let controller = getVisibleViewController()
        let alert = getAlert(title, message: message, cancelButtonTitle: cancelButtonTitle, cancelButtonCompletion:cancelButtonCompletion)
        controller?.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func showAlert(title:String?, message:String?, cancelButtonTitle:String?, cancelButtonCompletion:((action:UIAlertAction)->())?, actionButtonTitle:String?, actionButtonCompletion:((action:UIAlertAction)->())?) {
        let controller = getVisibleViewController()
        let alert = getAlert(title, message: message, cancelButtonTitle: cancelButtonTitle, cancelButtonCompletion:cancelButtonCompletion, actionButtonTitle: actionButtonTitle, actionButtonCompletion: actionButtonCompletion)
        controller?.presentViewController(alert, animated: true, completion: nil)
    }
    
}