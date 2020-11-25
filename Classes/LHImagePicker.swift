//
//  LHImagePicker.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import UIKit

@objc public protocol LHImagePickerDelegate {
  @objc optional func imagePicker(imagePicker: LHImagePicker, pickedImage: UIImage?)
  @objc optional func imagePickerDidCancel(imagePicker: LHImagePicker)

  @objc optional func imagePickerCropBorderClassForResizable(imagePicker: LHImagePicker) -> LHCropBorderView
}

@objc public class LHImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LHImageCropControllerDelegate {
  public var delegate: LHImagePickerDelegate?
  public var cropSize: CGSize!
  public var resizableCropArea = false

  private var _imagePickerController: UIImagePickerController!

  public var imagePickerController: UIImagePickerController {
    _imagePickerController
  }

  override public init() {
    super.init()

    self.cropSize = CGSize(width: 320, height: 320)
    self._imagePickerController = UIImagePickerController()
    _imagePickerController.delegate = self
    _imagePickerController.sourceType = .photoLibrary
  }

  private func hideController() {
    _imagePickerController.dismiss(animated: true, completion: nil)
  }

  public func imagePickerControllerDidCancel(_: UIImagePickerController) {
    if delegate?.imagePickerDidCancel != nil {
      delegate?.imagePickerDidCancel!(imagePicker: self)
    } else {
      hideController()
    }
  }

  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    let cropController = LHImageCropViewController()
    cropController.sourceImage = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
    cropController.resizableCropArea = resizableCropArea
    cropController.cropSize = cropSize
    cropController.cropBorderViewForResizable = delegate?.imagePickerCropBorderClassForResizable?(imagePicker: self)
    cropController.delegate = self
    picker.pushViewController(cropController, animated: true)
  }

  func imageCropController(imageCropController _: LHImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?) {
    delegate?.imagePicker?(imagePicker: self, pickedImage: croppedImage)
  }
}
