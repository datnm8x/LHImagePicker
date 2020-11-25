//
//  LHImageCropViewController.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import CoreGraphics
import UIKit

internal protocol LHImageCropControllerDelegate {
  func imageCropController(imageCropController: LHImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?)
}

internal class LHImageCropViewController: UIViewController {
  var sourceImage: UIImage?
  var delegate: LHImageCropControllerDelegate?
  var cropSize = CGSize(width: UIScreen.main.bounds.size.width - 60, height: UIScreen.main.bounds.size.width - 60)
  var resizableCropArea = false
  var cropBorderViewForResizable: LHCropBorderView?

  private var croppedImage: UIImage?

  private var imageCropView: LHImageCropView!
  private var toolbar: UIToolbar!
  private var useButton: UIButton!
  private var cancelButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false

    title = "Choose Photo"

    setupNavigationBar()
    setupCropView()
    setupToolbar()

    if UIDevice.current.userInterfaceIdiom == .phone {
      navigationController?.isNavigationBarHidden = true
    } else {
      navigationController?.isNavigationBarHidden = false
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    imageCropView.frame = view.bounds
    toolbar?.frame = CGRect(x: 0, y: view.frame.height - 54, width: view.frame.size.width, height: 54)
  }

  @objc func actionCancel(sender _: AnyObject) {
    navigationController?.popViewController(animated: true)
  }

  @objc func actionUse(sender _: AnyObject) {
    croppedImage = imageCropView.croppedImage()
    delegate?.imageCropController(imageCropController: self, didFinishWithCroppedImage: croppedImage)
  }

  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                       target: self, action: #selector(actionCancel))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Use", style: .plain,
                                                       target: self, action: #selector(actionUse))
  }

  private func setupCropView() {
    imageCropView = LHImageCropView(frame: view.bounds)
    imageCropView.imageToCrop = sourceImage
    imageCropView.cropBorderViewForResizable = cropBorderViewForResizable
    imageCropView.resizableCropArea = resizableCropArea
    imageCropView.cropSize = cropSize
    view.addSubview(imageCropView)
  }

  private func setupCancelButton() {
    cancelButton = UIButton()
    cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    cancelButton.titleLabel?.shadowOffset = CGSize(width: 0, height: -1)
    cancelButton.frame = CGRect(x: 0, y: 0, width: 58, height: 30)
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.setTitleShadowColor(
      UIColor(red: 0.118, green: 0.247, blue: 0.455, alpha: 1), for: .normal
    )
    cancelButton.addTarget(self, action: #selector(actionCancel), for: .touchUpInside)
  }

  private func setupUseButton() {
    useButton = UIButton()
    useButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    useButton.titleLabel?.shadowOffset = CGSize(width: 0, height: -1)
    useButton.frame = CGRect(x: 0, y: 0, width: 58, height: 30)
    useButton.setTitle("Use", for: .normal)
    useButton.setTitleShadowColor(
      UIColor(red: 0.118, green: 0.247, blue: 0.455, alpha: 1), for: .normal
    )
    useButton.addTarget(self, action: #selector(actionUse), for: .touchUpInside)
  }

  private func toolbarBackgroundImage() -> UIImage {
    let components: [CGFloat] = [1, 1, 1, 1, 123.0 / 255.0, 125.0 / 255.0, 132.0 / 255.0, 1]

    UIGraphicsBeginImageContextWithOptions(CGSize(width: 320, height: 54), true, 0)

    guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 2) else { return UIImage() }

    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 54), options: [])

    let viewImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return viewImage ?? UIImage()
  }

  private func setupToolbar() {
    guard UIDevice.current.userInterfaceIdiom == .phone else { return }

    toolbar = UIToolbar(frame: CGRect.zero)
    toolbar.isTranslucent = true
    toolbar.barStyle = .black
    view.addSubview(toolbar)

    setupCancelButton()
    setupUseButton()

    let info = UILabel(frame: CGRect.zero)
    info.text = ""
    info.textColor = UIColor(red: 0.173, green: 0.173, blue: 0.173, alpha: 1)
    info.backgroundColor = UIColor.clear
    info.shadowColor = UIColor(red: 0.827, green: 0.731, blue: 0.839, alpha: 1)
    info.shadowOffset = CGSize(width: 0, height: 1)
    info.font = UIFont.boldSystemFont(ofSize: 18)
    info.sizeToFit()

    let cancel = UIBarButtonItem(customView: cancelButton)
    let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let label = UIBarButtonItem(customView: info)
    let use = UIBarButtonItem(customView: useButton)

    toolbar.setItems([cancel, flex, label, flex, use], animated: false)
  }
}
