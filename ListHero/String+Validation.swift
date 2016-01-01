//
//  String+Validation.swift
//  ListHero
//
//  Created by BJ Griffin on 12/31/15.
//  Copyright © 2015 BJ Griffin. All rights reserved.
//

import Foundation

enum ValidateStringError: ErrorType {
    case AlphanumericOnly, AtLeastThreeCharacters
}

extension String {
    
    func validate() throws  {
        
        guard characters.count > 2
            else { throw ValidateStringError.AtLeastThreeCharacters }
        
        guard rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet, options: .LiteralSearch, range: nil) == nil
            else { throw ValidateStringError.AlphanumericOnly }
    }
}