//
//  NSAttributedString+Extensions.swift
//  TestUILabelHyperlink
//
//  Created by Colin Reisterer on 4/4/16.
//  Copyright © 2016 CRCode. All rights reserved.
//

import UIKit

extension NSAttributedString {
  
  func URLAtIndex(location: Int, effectiveRange: NSRangePointer) -> NSURL? {
    return attribute(NSLinkAttributeName, atIndex: location, effectiveRange: effectiveRange) as? NSURL
  }
  
}

extension NSMutableAttributedString {
 
  func textAsLink(textToFind: String, withLinkURL url: NSURL, linkColor: UIColor?=nil) -> Bool {
    let range = mutableString.rangeOfString(textToFind, options: .CaseInsensitiveSearch)
    if range.location != NSNotFound {
      addAttribute(NSLinkAttributeName, value: url, range: range)
      if let _linkColor = linkColor {
        addAttribute(NSForegroundColorAttributeName, value: _linkColor, range: range)
      }
      return true
    } else {
      return false
    }
  }

}
