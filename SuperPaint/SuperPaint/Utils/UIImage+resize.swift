//
//  UIImage+resize.swift
//  SuperPaint
//
//  Created by Stanislav on 23/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

extension UIImage
{
	func resizeImage(to dimension: CGFloat) -> UIImage? {
		guard max(size.width, size.height) > dimension else { return self }
		var newSize: CGSize
		let aspectRatio = size.width / size.height
		if aspectRatio > 1 {
			newSize = CGSize(width: dimension, height: dimension / aspectRatio)
		}
		else {
			newSize = CGSize(width: dimension * aspectRatio, height: dimension)
		}
		UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
		self.draw(in: CGRect(origin: .zero, size: newSize))
		defer { UIGraphicsEndImageContext() }
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}
