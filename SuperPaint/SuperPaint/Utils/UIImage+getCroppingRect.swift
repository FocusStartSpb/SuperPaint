//
//  UIImage+cropImage.swift
//  SuperPaint
//
//  Created by Stanislav on 12/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension UIImage
{
	func getCroppingRect(from imageRect: CGRect, to cropRect: CGRect) -> CGRect {
		let widthScale = self.size.width / imageRect.width
		let heightScale = self.size.height / imageRect.height
		var targetCropRect = cropRect
		print("Imagrect \(self.size)")
		targetCropRect.origin.x = (targetCropRect.origin.x - imageRect.origin.x) * widthScale
		targetCropRect.origin.y = (round(imageRect.origin.y + imageRect.height) -
			round(targetCropRect.origin.y + targetCropRect.height)) * heightScale
		targetCropRect.size.width *= widthScale
		targetCropRect.size.height *= heightScale

		return targetCropRect
	}
}
