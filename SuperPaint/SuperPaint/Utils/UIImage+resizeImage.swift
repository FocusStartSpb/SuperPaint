//
//  UIImage+resizeImage.swift
//  SuperPaint
//
//  Created by Иван Медведев on 16/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension UIImage
{
	func resizeImage(newHeight: CGFloat, completion: @escaping (UIImage?) -> Void) {
		let scale = newHeight / self.size.height
		let newWidth = self.size.width * scale
		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		completion(newImage)
	}
}
