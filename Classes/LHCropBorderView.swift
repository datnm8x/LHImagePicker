//
//  LHCropBorderView.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import UIKit

open class LHCropBorderView: UIView {
  private let kNumberOfBorderHandles: CGFloat = 8
  open var diameterSize: CGFloat = LHImagePicker.CropConfigs.diameterSize {
    didSet { setNeedsDisplay() }
  }

  open var lineWidth: CGFloat = LHImagePicker.CropConfigs.lineWidth {
    didSet { setNeedsDisplay() }
  }

  open var lineColor = LHImagePicker.CropConfigs.lineColor {
    didSet { setNeedsDisplay() }
  }

  open var diameterColor = LHImagePicker.CropConfigs.diameterColor {
    didSet { setNeedsDisplay() }
  }

  override public init(frame: CGRect = .zero) {
    super.init(frame: frame)

    self.backgroundColor = LHImagePicker.CropConfigs.backgroundColor
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.backgroundColor = LHImagePicker.CropConfigs.backgroundColor
  }

  override open func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()

    context?.setStrokeColor(lineColor.cgColor)
    context?.setLineWidth(lineWidth)
    context?.addRect(CGRect(x: diameterSize / 2, y: diameterSize / 2, width: rect.size.width - diameterSize, height: rect.size.height - diameterSize))
    context?.strokePath()
    context?.setFillColor(diameterColor.cgColor)

    for handleRect in calculateAllNeededHandleRects() {
      context?.fillEllipse(in: handleRect)
    }
  }

  private func calculateAllNeededHandleRects() -> [CGRect] {
    let width = frame.width
    let height = frame.height

    let leftColX: CGFloat = 0
    let rightColX = width - diameterSize
    let centerColX = rightColX / 2

    let topRowY: CGFloat = 0
    let bottomRowY = height - diameterSize
    let middleRowY = bottomRowY / 2

    // starting with the upper left corner and then following clockwise
    let topLeft = CGRect(x: leftColX, y: topRowY, width: diameterSize, height: diameterSize)
    let topCenter = CGRect(x: centerColX, y: topRowY, width: diameterSize, height: diameterSize)
    let topRight = CGRect(x: rightColX, y: topRowY, width: diameterSize, height: diameterSize)
    let middleRight = CGRect(x: rightColX, y: middleRowY, width: diameterSize, height: diameterSize)
    let bottomRight = CGRect(x: rightColX, y: bottomRowY, width: diameterSize, height: diameterSize)
    let bottomCenter = CGRect(x: centerColX, y: bottomRowY, width: diameterSize, height: diameterSize)
    let bottomLeft = CGRect(x: leftColX, y: bottomRowY, width: diameterSize, height: diameterSize)
    let middleLeft = CGRect(x: leftColX, y: middleRowY, width: diameterSize, height: diameterSize)

    return [topLeft, topCenter, topRight, middleRight, bottomRight, bottomCenter, bottomLeft,
            middleLeft]
  }
}
