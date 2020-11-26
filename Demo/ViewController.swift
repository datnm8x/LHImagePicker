//
//  ViewController.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LHImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  private var imagePicker: LHImagePicker!
  private var popoverController: UIPopoverController!
  private var imagePickerController: UIImagePickerController!

  private var customCropButton: UIButton!
  private var normalCropButton: UIButton!
  private var imageView: UIImageView!
  private var resizableButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    LHImagePicker.CropConfigs.ButtonsTitle.cancel = "キャンセル"
    LHImagePicker.CropConfigs.ButtonsTitle.use = "確定"

    customCropButton = UIButton()
    customCropButton.frame = UIDevice.current.userInterfaceIdiom == .pad ?
      CGRect(x: 20, y: 20, width: 220, height: 44) :
      CGRect(x: 20, y: customCropButton.frame.maxY + 64, width: view.bounds.width - 40, height: 44)
    customCropButton.setTitleColor(view.tintColor, for: .normal)
    customCropButton.setTitle("Custom Crop", for: .normal)
    customCropButton.addTarget(self, action: #selector(ViewController.showPicker(_:)), for: .touchUpInside)
    view.addSubview(customCropButton)

    normalCropButton = UIButton()
    normalCropButton.setTitleColor(view.tintColor, for: .normal)
    normalCropButton.setTitle("Apple's Build In Crop", for: .normal)
    normalCropButton.addTarget(self, action: #selector(ViewController.showNormalPicker(_:)), for: .touchUpInside)
    view.addSubview(normalCropButton)

    resizableButton = UIButton()
    resizableButton.setTitleColor(view.tintColor, for: .normal)
    resizableButton.setTitle("Resizable Custom Crop", for: .normal)
    resizableButton.addTarget(self, action: #selector(ViewController.showResizablePicker(_:)), for: .touchUpInside)
    view.addSubview(resizableButton)

    imageView = UIImageView(frame: CGRect.zero)
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = UIColor.gray
    view.addSubview(imageView)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    normalCropButton.frame = UIDevice.current.userInterfaceIdiom == .pad ?
      CGRect(x: 260, y: 20, width: 220, height: 44) :
      CGRect(x: 20, y: customCropButton.frame.maxY + 20, width: view.bounds.width - 40, height: 44)

    resizableButton.frame = UIDevice.current.userInterfaceIdiom == .pad ?
      CGRect(x: 500, y: 20, width: 220, height: 44) :
      CGRect(x: 20, y: normalCropButton.frame.maxY + 20, width: view.bounds.width - 40, height: 44)

    imageView.frame = UIDevice.current.userInterfaceIdiom == .pad ?
      CGRect(x: 20, y: 84, width: view.bounds.width - 40, height: view.bounds.height - 104) :
      CGRect(x: 20, y: resizableButton.frame.maxY + 20, width: view.bounds.width - 40, height: view.bounds.height - 20 - (resizableButton.frame.maxY + 20))
  }

  @objc func showPicker(_ button: UIButton) {
    imagePicker = LHImagePicker()
    imagePicker.delegate = self

    if UIDevice.current.userInterfaceIdiom == .pad {
      popoverController = UIPopoverController(contentViewController: imagePicker.imagePickerController)
      popoverController.present(from: button.frame, in: view, permittedArrowDirections: .any, animated: true)
    } else {
      present(imagePicker.imagePickerController, animated: true, completion: nil)
    }
  }

  @objc func showNormalPicker(_ button: UIButton) {
    imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true

    if UIDevice.current.userInterfaceIdiom == .pad {
      popoverController = UIPopoverController(contentViewController: imagePickerController)
      popoverController.present(from: button.frame, in: view, permittedArrowDirections: .any, animated: true)
    } else {
      present(imagePickerController, animated: true, completion: nil)
    }
  }

  @objc func showResizablePicker(_ button: UIButton) {
    imagePicker = LHImagePicker()
    imagePicker.delegate = self
    imagePicker.resizableCropArea = true

    if UIDevice.current.userInterfaceIdiom == .pad {
      popoverController = UIPopoverController(contentViewController: imagePicker.imagePickerController)
      popoverController.present(from: button.frame, in: view, permittedArrowDirections: .any, animated: true)
    } else {
      present(imagePicker.imagePickerController, animated: true, completion: nil)
    }
  }

  func imagePicker(imagePicker _: LHImagePicker, pickedImage: UIImage?) {
    imageView.image = pickedImage
    hideImagePicker()
  }

  func hideImagePicker() {
    if UIDevice.current.userInterfaceIdiom == .pad {
      popoverController.dismiss(animated: true)
    } else {
      imagePicker.imagePickerController.dismiss(animated: true, completion: nil)
    }
  }

  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo _: [NSObject: AnyObject]!) {
    imageView.image = image

    if UIDevice.current.userInterfaceIdiom == .pad {
      popoverController.dismiss(animated: true)
    } else {
      picker.dismiss(animated: true, completion: nil)
    }
  }
}
