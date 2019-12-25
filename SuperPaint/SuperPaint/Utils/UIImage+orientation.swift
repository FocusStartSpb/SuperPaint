//
//  UIImage+orientation.swift
//  SuperPaint
//
//  Created by Иван Медведев on 25/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

extension UIImage
{
	func verticalOrientationImage() -> UIImage? {
		switch imageOrientation {
		case .up:
			return self
		default:
			UIGraphicsBeginImageContextWithOptions(size, false, scale)
			draw(in: CGRect(origin: .zero, size: size))
			let result = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return result
		}
	}
}
