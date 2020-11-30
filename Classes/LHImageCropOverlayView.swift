//
//  LHImageCropOverlayView.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import UIKit

internal class LHImageCropOverlayView: UIView {
  var cropSize: CGSize!
  var toolbar: UIToolbar!

  open var lineWidth: CGFloat = LHImagePicker.CropConfigs.lineWidth {
    didSet { setNeedsDisplay() }
  }

  open var lineColor = LHImagePicker.CropConfigs.lineColor {
    didSet { setNeedsDisplay() }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = UIColor.clear
    self.isUserInteractionEnabled = true
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.backgroundColor = UIColor.clear
    self.isUserInteractionEnabled = true
  }

  override func draw(_: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    let toolbarSize = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 0 : 54)

    let width = frame.width
    let height = frame.height - toolbarSize

    let heightSpan = floor(height / 2 - cropSize.height / 2)
    let widthSpan = floor(width / 2 - cropSize.width / 2)

    // fill outer rect
    LHImagePicker.CropConfigs.backgroundColor.set()
    UIRectFill(bounds)

    context.setLineWidth(lineWidth)
    context.setStrokeColor(lineColor.cgColor)
    context.addRect(
      CGRect(
        x: widthSpan,
        y: heightSpan,
        width: cropSize.width,
        height: cropSize.height
      )
    )
    context.strokePath()

    // fill inner rect
    UIColor.clear.set()
    UIRectFill(
      CGRect(
        x: widthSpan,
        y: heightSpan,
        width: cropSize.width,
        height: cropSize.height
      )
    )
  }
}
