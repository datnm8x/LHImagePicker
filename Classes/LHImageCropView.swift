//
//  LHImageCropView.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import QuartzCore
import UIKit

private class LHImageCropScrollView: UIScrollView {
//  override fileprivate func layoutSubviews() {
//    super.layoutSubviews()
//
//    guard let zoomView = delegate?.viewForZooming?(in: self) else { return }
//
//    let boundsSize = bounds.size
//    var frameToCenter = zoomView.frame
//
//    // center horizontally
//    if frameToCenter.size.width < boundsSize.width {
//      frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
//    } else {
//      frameToCenter.origin.x = 0
//    }
//
//    // center vertically
//    if frameToCenter.size.height < boundsSize.height {
//      frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
//    } else {
//      frameToCenter.origin.y = 0
//    }
//
//    zoomView.frame = frameToCenter
//  }
}

internal class LHImageCropView: UIView, UIScrollViewDelegate {
  private var scrollView: UIScrollView!
  private var imageView = UIImageView(frame: .zero)
  private let cropOverlayView = LHCropOverlayView(frame: .zero)
  var imageToCrop: UIImage? {
    get { imageView.image }
    set { imageView.image = newValue }
  }

  var resizableCropArea: Bool {
    get { cropOverlayView.resizableCropArea }
    set { cropOverlayView.resizableCropArea = newValue }
  }

  private var cropSize: CGSize { LHImagePicker.CropConfigs.cropSize }
  private var xOffset: CGFloat { floor((bounds.width - cropSize.width) * 0.5) }
  private var yOffset: CGFloat { floor((bounds.height - toolbarHeight - cropSize.height) * 0.5) }
  private var factoredRect: CGRect {
    guard let imageToCrop = self.imageToCrop else { return .zero }

    let height = imageToCrop.size.height
    let width = imageToCrop.size.width

    var factor: CGFloat = 0
    var factoredHeight: CGFloat = cropSize.height
    var factoredWidth: CGFloat = cropSize.width

    if width > height {
      factor = width / cropSize.width
      factoredHeight = height / factor
    } else {
      factor = height / cropSize.height
      factoredWidth = width / factor
    }

    return CGRect(x: 0, y: 0, width: factoredWidth, height: factoredHeight)
  }

  var minimumScale: CGFloat {
    guard let imageToCrop = self.imageToCrop else { return 1 }

    var minScale = max(cropSize.height / imageView.frame.height, cropSize.width / imageView.frame.width)
    minScale = max(minScale, max(imageView.frame.height / cropSize.height, imageView.frame.width / cropSize.width))
    let scaleFitBounds = min(bounds.width / cropSize.width, bounds.height / cropSize.height)

    let ratioFitImage = min(imageToCrop.size.height / imageView.frame.height, imageToCrop.size.width / imageView.frame.width)
    let widthImageScaled = (imageToCrop.size.width / ratioFitImage) * scaleFitBounds
    let HeightImageScaled = (imageToCrop.size.height / ratioFitImage) * scaleFitBounds

    return widthImageScaled < cropSize.width || HeightImageScaled < cropSize.height ? minScale : min(minScale, scaleFitBounds)
  }

  private static func scaleRect(rect: CGRect, scale: CGFloat) -> CGRect {
    CGRect(
      x: rect.origin.x * scale,
      y: rect.origin.y * scale,
      width: rect.size.width * scale,
      height: rect.size.height * scale
    )
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    translatesAutoresizingMaskIntoConstraints = false
    self.isUserInteractionEnabled = true
    self.backgroundColor = UIColor.black
    self.scrollView = LHImageCropScrollView(frame: frame)
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.delegate = self
    scrollView.clipsToBounds = false
    scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
    scrollView.backgroundColor = UIColor.clear
    addSubview(scrollView)

    imageView.frame = scrollView.bounds
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

    addSubview(cropOverlayView)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  @objc private func didTap() {
    let minScale = minimumScale
    let zoom: CGFloat = scrollView.zoomScale > minScale ? minScale : minScale * 2
    scrollView.setZoomScale(zoom, animated: true)
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard resizableCropArea else { return scrollView }

    let outerFrame = cropOverlayView.cropBorderView.frame.insetBy(dx: -10, dy: -10)

    if outerFrame.contains(point) {
      if cropOverlayView.cropBorderView.frame.size.width < 60 ||
        cropOverlayView.cropBorderView.frame.size.height < 60
      {
        return super.hitTest(point, with: event)
      }

      let innerTouchFrame = cropOverlayView.cropBorderView.frame.insetBy(dx: 30, dy: 30)
      if innerTouchFrame.contains(point) {
        return scrollView
      }

      let outBorderTouchFrame = cropOverlayView.cropBorderView.frame.insetBy(dx: -10, dy: -10)
      if outBorderTouchFrame.contains(point) {
        return super.hitTest(point, with: event)
      }

      return super.hitTest(point, with: event)
    }

    return scrollView
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    imageView.image = imageToCrop
    cropOverlayView.frame = bounds
    scrollView.frame = CGRect(x: xOffset, y: yOffset, width: cropSize.width, height: cropSize.height)
    scrollView.contentSize = cropSize
    imageView.frame = scrollView.bounds
    imageView.frame = factoredRect
    scrollView.minimumZoomScale = minimumScale
    scrollView.setZoomScale(max(bounds.width / cropSize.width, minimumScale), animated: false)
  }

  func viewForZooming(in _: UIScrollView) -> UIView? {
    imageView
  }

  func croppedImage() -> UIImage? {
    guard let imageToCrop = self.imageToCrop else { return nil }

    // Calculate rect that needs to be cropped
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
    guard let imageToCrop = self.imageToCrop else { return .zero }

    // first of all, get the size scale by taking a look at the real image dimensions. Here it
    // doesn't matter if you take the width or the hight of the image, because it will always
    // be scaled in the exact same proportion of the real image
    var sizeScale = imageToCrop.size.width / imageView.frame.size.width
    sizeScale *= scrollView.zoomScale

    // then get the postion of the cropping rect inside the image
    var visibleRect = cropOverlayView.contentView.convert(cropOverlayView.contentView.bounds,
                                                          to: imageView)
    visibleRect = LHImageCropView.scaleRect(rect: visibleRect, scale: sizeScale)

    return visibleRect
  }

  private func calcVisibleRectForCropArea() -> CGRect {
    guard let imageToCrop = self.imageToCrop else { return .zero }

    // scaled width/height in regards of real width to crop width
    let scaleWidth = imageToCrop.size.width / cropSize.width
    let scaleHeight = imageToCrop.size.height / cropSize.height
    var scale: CGFloat = 0

    if cropSize.width == cropSize.height {
      scale = max(scaleWidth, scaleHeight)
    } else if cropSize.width > cropSize.height {
      scale = imageToCrop.size.width < imageToCrop.size.height ?
        max(scaleWidth, scaleHeight) :
        min(scaleWidth, scaleHeight)
    } else {
      scale = imageToCrop.size.width < imageToCrop.size.height ?
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
