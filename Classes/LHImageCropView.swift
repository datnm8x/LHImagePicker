//
//  LHImageCropView.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import QuartzCore
import UIKit

private class ScrollView: UIScrollView {
  override fileprivate func layoutSubviews() {
    super.layoutSubviews()

    guard let zoomView = delegate?.viewForZooming?(in: self) else { return }

    let boundsSize = bounds.size
    var frameToCenter = zoomView.frame

    // center horizontally
    if frameToCenter.size.width < boundsSize.width {
      frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
    } else {
      frameToCenter.origin.x = 0
    }

    // center vertically
    if frameToCenter.size.height < boundsSize.height {
      frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
    } else {
      frameToCenter.origin.y = 0
    }

    zoomView.frame = frameToCenter
  }
}

internal class LHImageCropView: UIView, UIScrollViewDelegate {
  var resizableCropArea = false

  private var scrollView: UIScrollView!
  private var imageView: UIImageView!
  private var cropOverlayView: LHImageCropOverlayView!
  private var xOffset: CGFloat!
  private var yOffset: CGFloat!

  private static func scaleRect(rect: CGRect, scale: CGFloat) -> CGRect {
    CGRect(
      x: rect.origin.x * scale,
      y: rect.origin.y * scale,
      width: rect.size.width * scale,
      height: rect.size.height * scale
    )
  }

  var imageToCrop: UIImage? {
    get {
      imageView.image
    }
    set {
      imageView.image = newValue
    }
  }

  var cropSize: CGSize {
    get {
      self.cropOverlayView.cropSize
    }
    set {
      if let view = self.cropOverlayView {
        view.cropSize = newValue
      } else {
        if self.resizableCropArea {
          let overlayView = LHResizableCropOverlayView(
            frame: self.bounds,
            initialContentSize: CGSize(width: newValue.width, height: newValue.height),
            cropBorderViewForResizable: cropBorderViewForResizable
          )
          overlayView.cropBorderView.diameterSize = cropDiameterSize
          self.cropOverlayView = overlayView
        } else {
          self.cropOverlayView = LHImageCropOverlayView(frame: self.bounds)
        }
        self.cropOverlayView.cropSize = newValue
        self.addSubview(self.cropOverlayView)
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.isUserInteractionEnabled = true
    self.backgroundColor = UIColor.black
    self.scrollView = ScrollView(frame: frame)
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.delegate = self
    scrollView.clipsToBounds = false
    scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
    scrollView.backgroundColor = UIColor.clear
    addSubview(scrollView)

    self.imageView = UIImageView(frame: scrollView.frame)
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = UIColor.black
    scrollView.addSubview(imageView)

    scrollView.minimumZoomScale =
      scrollView.frame.width / scrollView.frame.height
    scrollView.maximumZoomScale = 20
    scrollView.setZoomScale(1.0, animated: false)

    let tapGes = UITapGestureRecognizer(target: self, action: #selector(didTap))
    tapGes.numberOfTapsRequired = 2
    scrollView.addGestureRecognizer(tapGes)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  @objc private func didTap() {
    let zoom: CGFloat = scrollView.zoomScale > 1 ? 1 : 2
    scrollView.setZoomScale(zoom, animated: true)
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard resizableCropArea else { return scrollView }

    let resizableCropView = cropOverlayView as! LHResizableCropOverlayView
    let outerFrame = resizableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10)

    if outerFrame.contains(point) {
      if resizableCropView.cropBorderView.frame.size.width < 60 ||
        resizableCropView.cropBorderView.frame.size.height < 60
      {
        return super.hitTest(point, with: event)
      }

      let innerTouchFrame = resizableCropView.cropBorderView.frame.insetBy(dx: 30, dy: 30)
      if innerTouchFrame.contains(point) {
        return scrollView
      }

      let outBorderTouchFrame = resizableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10)
      if outBorderTouchFrame.contains(point) {
        return super.hitTest(point, with: event)
      }

      return super.hitTest(point, with: event)
    }

    return scrollView
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let size = cropSize
    let toolbarSize = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 0 : 54)
    xOffset = floor((bounds.width - size.width) * 0.5)
    yOffset = floor((bounds.height - toolbarSize - size.height) * 0.5)

    let height = imageToCrop!.size.height
    let width = imageToCrop!.size.width

    var factor: CGFloat = 0
    var factoredHeight: CGFloat = 0
    var factoredWidth: CGFloat = 0

    if width > height {
      factor = width / size.width
      factoredWidth = size.width
      factoredHeight = height / factor
    } else {
      factor = height / size.height
      factoredWidth = width / factor
      factoredHeight = size.height
    }

    cropOverlayView.frame = bounds
    scrollView.frame = CGRect(x: xOffset, y: yOffset, width: size.width, height: size.height)
    scrollView.contentSize = CGSize(width: size.width, height: size.height)
    imageView.frame = CGRect(x: 0, y: floor((size.height - factoredHeight) * 0.5),
                             width: factoredWidth, height: factoredHeight)
  }

  func viewForZooming(in _: UIScrollView) -> UIView? {
    imageView
  }

  func croppedImage() -> UIImage? {
    // Calculate rect that needs to be cropped
    guard let imageToCrop = imageToCrop else { return nil }

    var visibleRect = resizableCropArea ?
      calcVisibleRectForResizeableCropArea() : calcVisibleRectForCropArea()

    // transform visible rect to image orientation
    let rectTransform = orientationTransformedRectOfImage(image: imageToCrop)
    visibleRect = visibleRect.applying(rectTransform)

    // finally crop image
    guard let cgImage = imageToCrop.cgImage else { return nil }

    guard let imageRef = cgImage.cropping(to: visibleRect) else { return nil }
    let result = UIImage(cgImage: imageRef, scale: imageToCrop.scale,
                         orientation: imageToCrop.imageOrientation)

    return result
  }

  private func calcVisibleRectForResizeableCropArea() -> CGRect {
    let resizableView = cropOverlayView as! LHResizableCropOverlayView

    // first of all, get the size scale by taking a look at the real image dimensions. Here it
    // doesn't matter if you take the width or the hight of the image, because it will always
    // be scaled in the exact same proportion of the real image
    var sizeScale = imageView.image!.size.width / imageView.frame.size.width
    sizeScale *= scrollView.zoomScale

    // then get the postion of the cropping rect inside the image
    var visibleRect = resizableView.contentView.convert(resizableView.contentView.bounds,
                                                        to: imageView)
    visibleRect = LHImageCropView.scaleRect(rect: visibleRect, scale: sizeScale)

    return visibleRect
  }

  private func calcVisibleRectForCropArea() -> CGRect {
    // scaled width/height in regards of real width to crop width
    let scaleWidth = imageToCrop!.size.width / cropSize.width
    let scaleHeight = imageToCrop!.size.height / cropSize.height
    var scale: CGFloat = 0

    if cropSize.width == cropSize.height {
      scale = max(scaleWidth, scaleHeight)
    } else if cropSize.width > cropSize.height {
      scale = imageToCrop!.size.width < imageToCrop!.size.height ?
        max(scaleWidth, scaleHeight) :
        min(scaleWidth, scaleHeight)
    } else {
      scale = imageToCrop!.size.width < imageToCrop!.size.height ?
        min(scaleWidth, scaleHeight) :
        max(scaleWidth, scaleHeight)
    }

    // extract visible rect from scrollview and scale it
    var visibleRect = scrollView.convert(scrollView.bounds, to: imageView)
    visibleRect = LHImageCropView.scaleRect(rect: visibleRect, scale: scale)

    return visibleRect
  }

  private func orientationTransformedRectOfImage(image: UIImage) -> CGAffineTransform {
    var rectTransform: CGAffineTransform!

    switch image.imageOrientation {
    case .left:
      rectTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2).translatedBy(
        x: 0, y: -image.size.height
      )
    case .right:
      rectTransform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2).translatedBy(
        x: -image.size.width, y: 0
      )
    case .down:
      rectTransform = CGAffineTransform(rotationAngle: -CGFloat.pi).translatedBy(
        x: -image.size.width, y: -image.size.height
      )
    default:
      rectTransform = .identity
    }

    return rectTransform.scaledBy(x: image.scale, y: image.scale)
  }
}
