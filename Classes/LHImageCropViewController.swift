//
//  LHImageCropViewController.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import CoreGraphics
import UIKit

internal let toolbarHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 0 : 44

internal protocol LHImageCropControllerDelegate {
  func imageCropController(imageCropController: LHImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?)
}

internal class LHImageCropViewController: UIViewController {
  var sourceImage: UIImage? {
    get { imageCropView.imageToCrop }
    set { imageCropView.imageToCrop = newValue }
  }

  var delegate: LHImageCropControllerDelegate?
  var resizableCropArea: Bool {
    get { imageCropView.resizableCropArea }
    set { imageCropView.resizableCropArea = newValue }
  }

  private let imageCropView = LHImageCropView(frame: .zero)
  private var toolbar: UIToolbar!
  private var useButton: UIButton!
  private var cancelButton: UIButton!
  private var croppedImage: UIImage?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Choose Photo"
    navigationController?.isNavigationBarHidden = UIDevice.current.userInterfaceIdiom == .phone
    automaticallyAdjustsScrollViewInsets = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard imageCropView.superview != view else { return }

    setupNavigationBar()
    setupCropView()
    setupToolbar()
  }

  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                       target: self, action: #selector(actionCancel))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Use", style: .plain,
                                                       target: self, action: #selector(actionUse))
  }

  private func setupCropView() {
    imageCropView.frame = view.bounds
    view.addSubview(imageCropView)
    imageCropView.constraintToSuperViewLHImagePicker()
  }

  private func setupCancelButton() {
    cancelButton = UIButton()
    cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    cancelButton.titleLabel?.shadowOffset = CGSize(width: 0, height: -1)
    cancelButton.frame = CGRect(x: 0, y: 0, width: 58, height: 30)
    cancelButton.setTitle(LHImagePicker.CropConfigs.ButtonsTitle.cancel, for: .normal)
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
    useButton.setTitle(LHImagePicker.CropConfigs.ButtonsTitle.use, for: .normal)
    useButton.setTitleShadowColor(
      UIColor(red: 0.118, green: 0.247, blue: 0.455, alpha: 1), for: .normal
    )
    useButton.addTarget(self, action: #selector(actionUse), for: .touchUpInside)
  }

  private func toolbarBackgroundImage() -> UIImage {
    let components: [CGFloat] = [1, 1, 1, 0.5, 123.0 / 255.0, 125.0 / 255.0, 132.0 / 255.0, 0.5]

    UIGraphicsBeginImageContextWithOptions(CGSize(width: UIScreen.main.bounds.width, height: toolbarHeight), true, 0)

    guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 2) else { return UIImage() }

    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: toolbarHeight), options: [])

    let viewImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return viewImage ?? UIImage()
  }

  private func setupToolbar() {
    guard UIDevice.current.userInterfaceIdiom == .phone else { return }

    toolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.height - view.safeAreaInsetsLHImagePicker.bottom, width: view.frame.width, height: toolbarHeight))
    toolbar.translatesAutoresizingMaskIntoConstraints = false
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

    if #available(iOS 11.0, *) {
      toolbar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
      toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
      toolbar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    } else {
      // Fallback on earlier versions
      toolbar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
      toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
      toolbar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight).isActive = true
  }

  deinit {
    print("Release LHImageCropViewController")
  }
}

extension LHImageCropViewController {
  @objc func actionCancel(sender _: AnyObject) {
    imageCropView.removeFromSuperview()
    navigationController?.popViewController(animated: true)
  }

  @objc func actionUse(sender _: AnyObject) {
    croppedImage = imageCropView.croppedImage()
    delegate?.imageCropController(imageCropController: self, didFinishWithCroppedImage: croppedImage)
  }
}
