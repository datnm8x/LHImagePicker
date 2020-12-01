//
//  UIView+Constraint.swift
//  LHImagePicker
//
//  Created by Nguyen Mau Dat on 30/11/2020.
//  Copyright © 2020 Dat Ng. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  /// Constraints a view to its superview
  func constraintToSuperViewLHImagePicker() {
    guard let superview = superview else { return }
    translatesAutoresizingMaskIntoConstraints = false

    topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
    leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
    bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
  }

  /// Constraints a view to its superview safe area
  func constraintToSafeAreaLHImagePicker() {
    guard let superview = superview else { return }
    translatesAutoresizingMaskIntoConstraints = false

    if #available(iOS 11.0, *) {
      topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor).isActive = true
      leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor).isActive = true
      bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
      rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor).isActive = true
    } else {
      // Fallback on earlier versions
      topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
      leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
      bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
      rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
    }
  }

  var safeAreaInsetsLHImagePicker: UIEdgeInsets {
    if #available(iOS 11.0, *) { return safeAreaInsets }
    else { return .zero }
  }
}
