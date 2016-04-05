//
//  ViewController.swift
//  UILabelHyperlinks
//
//  Created by Colin Reisterer on 4/5/16.
//  Copyright © 2016 creister. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var label: LinkLabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let string = NSMutableAttributedString(string: label.text ?? "")
    let url = NSURL(string: "http://www.google.com")!
    string.textAsLink("Google", withLinkURL: url, linkColor: UIColor.orangeColor())
    
    // our custom label does not extract attributed properties from label with non-attributed string, so let's set font explicitly
    string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(17), range: NSRange(location: 0, length: string.length))
    
    label.attributedText = string
    label.selectedLinkBackgroundColor = UIColor.lightGrayColor()
    
    label.linkTapHandler = { url in
      UIApplication.sharedApplication().openURL(url)
    }    

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

