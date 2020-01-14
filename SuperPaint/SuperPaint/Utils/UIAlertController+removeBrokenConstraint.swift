//
//  UIAlertController+removeBrokenConstraint.swift
//  SuperPaint
//
//  Created by Иван Медведев on 14/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension UIAlertController
{
	func removeBrokenConstraint() {
		for subView in self.view.subviews {
			for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
				subView.removeConstraint(constraint)
			}
		}
	}
}
