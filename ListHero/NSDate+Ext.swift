//
//  NSDate+Ext.swift
//  ListHero
//
//  Created by BJ Griffin on 12/20/15.
//  Copyright © 2015 BJ Griffin. All rights reserved.
//

import Foundation

extension NSDate {
    class func dateFormatted(var date:NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
        components.hour = 0
        components.minute = 1
        components.second = 0
        let morningStart = calendar.dateFromComponents(components)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strFromDate = formatter.stringFromDate(morningStart!)
        date = formatter.dateFromString(strFromDate)!
        
        return date
    }
}