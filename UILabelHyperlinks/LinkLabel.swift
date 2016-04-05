//
//  LinkLabel.swift
//  TestUILabelHyperlink
//
//  Created by Colin Reisterer on 4/4/16.
//  Copyright © 2016 CRCode. All rights reserved.
//

import UIKit

class LinkLabel: UILabel {
  
  var selectedLinkBackgroundColor: UIColor? = nil
  
  var linkTapHandler: (NSURL -> Void)?
  
  lazy var textStorage: NSTextStorage = {
    let t = NSTextStorage()
    t.addLayoutManager(self.layoutManager)
    return t
  }()
  
  lazy var textContainer: NSTextContainer = {
    let t = NSTextContainer()
    t.lineFragmentPadding = 0
    t.maximumNumberOfLines = self.numberOfLines
    t.lineBreakMode = self.lineBreakMode
    t.widthTracksTextView = true
    t.size = self.frame.size
    return t
  }()
  
  lazy var layoutManager: NSLayoutManager = {
    let l = LayoutManager()
    l.delegate = self
    l.addTextContainer(self.textContainer)
    return l
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    textContainer.size = self.bounds.size
  }
  
  override var frame: CGRect {
    didSet {
      var size = frame.size
      size.width = min(size.width, self.preferredMaxLayoutWidth)
      size.height = 0
      self.textContainer.size = size
    }
  }
  
  override var bounds: CGRect {
    didSet {
      var size = bounds.size
      size.width = min(size.width, self.preferredMaxLayoutWidth)
      size.height = 0
      self.textContainer.size = size
    }
  }
  
  override var preferredMaxLayoutWidth: CGFloat {
    didSet {
      var size = bounds.size
      size.width = min(size.width, self.preferredMaxLayoutWidth)
      self.textContainer.size = size
    }
  }
  
  override var attributedText: NSAttributedString? {
    didSet {
      if let _t = attributedText {
        self.textStorage.setAttributedString(_t)
      }
    }
  }
  
  override func drawTextInRect(rect: CGRect) {
    // calculate the offset of the text in the view
    let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
    let textOffset = _textOffsetForGlyphRange(glyphRange)
    
    // drawing code
    layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: textOffset)
    
    // for debugging the following 2 line should produce the same results
    layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: textOffset)
    // super.drawTextInRect(rect)
  }
  
  override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    // user our text container to calculate the bounds required. first save our current text container setup.
    let savedTextContainerSize = textContainer.size
    let savedTextContainerNumberOfLines = textContainer.maximumNumberOfLines
    
    // apply the new potential bounds and nubmer of lines
    textContainer.size = bounds.size
    textContainer.maximumNumberOfLines = numberOfLines
    
    // measure the text with the new state
    let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
    var textBounds = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
    
    // position the bounds and round up the size for good measure
    textBounds.origin = bounds.origin
    textBounds.size.width = ceil(textBounds.size.width)
    textBounds.size.height = ceil(textBounds.size.height)
    
    textContainer.size = savedTextContainerSize
    textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines
    
    return textBounds
  }
  
  var selectedRange = NSRange(location: 0, length: 0) {
    willSet {
      // remove the current selection if the selection is changing
      if self.selectedRange.length > 0 && !NSEqualRanges(selectedRange, newValue) {
        self.textStorage.removeAttribute(NSBackgroundColorAttributeName, range: self.selectedRange)
      }
      
      // apply the new selection to the text
      if newValue.length > 0 {
        if let _selectedLinkBackgroundColor = selectedLinkBackgroundColor {
          textStorage.addAttribute(NSBackgroundColorAttributeName, value: _selectedLinkBackgroundColor, range: newValue)
        }
      }
    }
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonSetup()
  }
  
  func commonSetup() {
    // make sure user interaction is enabled so we can accept touches
    userInteractionEnabled = true
    
    // attach a default detection handler to help with debugging
    self.linkTapHandler = { url in
      print("Default handler for \(url)")
    }
    
    let touch = TouchGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
    touch.delegate = self
    self.addGestureRecognizer(touch)
  }
  
  func handleTouch(gesture: TouchGestureRecognizer) {
    // get the info for the touched link if there is one
    let touchLocation = gesture.locationInView(self)
    let index = _stringIndexAtLocation(touchLocation)
    
    var effectiveRange = NSRange()
    var touchedURL: NSURL? = nil
    
    if index != NSNotFound {
      touchedURL = attributedText!.URLAtIndex(index, effectiveRange: &effectiveRange)
    }
    
    switch gesture.state {
    case .Began:
      if touchedURL != nil {
        selectedRange = effectiveRange
      } else {
        // no URL, cancel gesture
        gesture.enabled = false
        gesture.enabled = true
      }
    case .Ended:
      if let _touchedURL = touchedURL, _linkTapHandler = linkTapHandler {
        _linkTapHandler(_touchedURL)
      }
      selectedRange = NSRange(location: 0, length: 0)
    default:
      selectedRange = NSRange(location: 0, length: 0)
    }
  }
  
  
}


extension LinkLabel: NSLayoutManagerDelegate {
  
  
}

extension LinkLabel: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    let touchLocation = touch.locationInView(self)
    let index = _stringIndexAtLocation(touchLocation)
    var effectiveRange = NSRange()
    var touchedURL: NSURL? = nil
    
    if index != NSNotFound {
      touchedURL = attributedText?.URLAtIndex(index, effectiveRange: &effectiveRange)
    }
    
    if touchedURL != nil {
      return true
    } else {
      return false
    }
  }
  
}


// helpers
extension LinkLabel {
  
  private func _textOffsetForGlyphRange(glyphRange: NSRange) -> CGPoint {
    var textOffset = CGPointZero
    let textBounds = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
    let paddingHeight = (bounds.size.height - textBounds.size.height) / 2
    if paddingHeight > 0 {
      textOffset.y = paddingHeight
    }
    return textOffset
  }
  
  func _stringIndexAtLocation(location: CGPoint) -> Int {
    // do nothing if we have no text
    if textStorage.string.characters.count == 0 {
      return NSNotFound
    }
    
    // work out the offset of the text in the view
    let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer)
    let textOffset = _textOffsetForGlyphRange(glyphRange)
    
    // get the touch location and use text offset to convert to text container coordinates
    var location = location
    location.x -= textOffset.x
    location.y -= textOffset.y
    
    let glyphIndex = layoutManager.glyphIndexForPoint(location, inTextContainer: textContainer)
    
    // if the touch is in the white space after the last glyph on the line
    // we don't count it as a hit on the text
    var lineRange = NSRange()
    let lineRect = layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, effectiveRange: &lineRange)
    if !CGRectContainsPoint(lineRect, location) {
      return NSNotFound
    }
    return layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
  }
  
}
