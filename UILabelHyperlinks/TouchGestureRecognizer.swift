//
//  TouchGestureRecognizer.swift
//  TestUILabelHyperlink
//
//  Created by Colin Reisterer on 4/4/16.
//  Copyright © 2016 CRCode. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchGestureRecognizer: UIGestureRecognizer {
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    state = UIGestureRecognizerState.Began
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
    state = .Failed
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
    state = .Ended
  }
  
  override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
    state = .Cancelled
  }
  
}
