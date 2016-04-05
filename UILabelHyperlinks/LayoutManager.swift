//
//  LayoutManager.swift
//  TestUILabelHyperlink
//
//  Created by Colin Reisterer on 4/4/16.
//  Copyright © 2016 CRCode. All rights reserved.
//

import UIKit

class LayoutManager: NSLayoutManager {
  
  override func drawUnderlineForGlyphRange(glyphRange: NSRange, underlineType underlineVal: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect lineRect: CGRect, lineFragmentGlyphRange lineGlyphRange: NSRange, containerOrigin: CGPoint) {
    // do nothing, we don't want underlines
  }
  
  override func showCGGlyphs(glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, matrix textMatrix: CGAffineTransform, attributes: [String : AnyObject], inContext graphicsContext: CGContext) {
    let foregroundColor = attributes[NSForegroundColorAttributeName] as? UIColor
    if let _foregroundColor = foregroundColor {
      CGContextSetFillColorWithColor(graphicsContext, _foregroundColor.CGColor)
    }
    super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, matrix: textMatrix, attributes: attributes, inContext: graphicsContext)
  }
  
}