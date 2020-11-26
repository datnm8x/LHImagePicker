//
//  LHImagePicker.swift
//  LHImagePicker
//
//  Created by Dat Ng on 11/2020.
//  Copyright (c) 2020 Dat Ng. All rights reserved.
//

import UIKit

public extension LHImagePicker {
  enum CropConfigs {
    public static var diameterSize: CGFloat = 6
    public static var lineWidth: CGFloat = 1.5
    public static var lineColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    public static var diameterColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.95)
    public static var cropSize = CGSize(width: 300, height: 300)

    public enum ButtonsTitle {
      public static var cancel: String = "Cancel"
      public static var use: String = "Use"
    }
  }
}

@objc public protocol LHImagePickerDelegate: NSObjectProtocol {
  @objc optional func imagePicker(imagePicker: LHImagePicker, pickedImage: UIImage?)
  @objc optional func imagePickerDidCancel(imagePicker: LHImagePicker)

  @objc optional func imagePickerCropBorderClassForResizable(imagePicker: LHImagePicker) -> LHCropBorderView
}

@objc public class LHImagePicker: NSObject {
  public var delegate: LHImagePickerDelegate?
  public var resizableCropArea = false
  private lazy var pickerDelegateHandler = LHImagePickerDelegateHandler()

  private var _imagePickerController: UIImagePickerController!

  public var imagePickerController: UIImagePickerController {
    _imagePickerController
  }

  override public init() {
    super.init()

    pickerDelegateHandler.imagePicker = self
    self._imagePickerController = UIImagePickerController()
    _imagePickerController.delegate = pickerDelegateHandler
    _imagePickerController.sourceType = .photoLibrary
  }
}

extension LHImagePicker: LHImageCropControllerDelegate {
  func imageCropController(imageCropController _: LHImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?) {
    delegate?.imagePicker?(imagePicker: self, pickedImage: croppedImage)
  }
}

internal class LHImagePickerDelegateHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  weak var imagePicker: LHImagePicker?

  internal func imagePickerControllerDidCancel(_ pickerController: UIImagePickerController) {
    pickerController.dismiss(animated: true, completion: nil)
    guard let imagePicker = self.imagePicker else { return }

    imagePicker.delegate?.imagePickerDidCancel?(imagePicker: imagePicker)
  }

  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    guard let imagePicker = self.imagePicker, let originalImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else {
      picker.dismiss(animated: true, completion: nil)
      return
    }

    let cropController = LHImageCropViewController()
    cropController.sourceImage = originalImage
    cropController.resizableCropArea = imagePicker.resizableCropArea
    cropController.cropBorderViewForResizable = imagePicker.delegate?.imagePickerCropBorderClassForResizable?(imagePicker: imagePicker)
    cropController.delegate = imagePicker
    picker.pushViewController(cropController, animated: true)
  }
}
