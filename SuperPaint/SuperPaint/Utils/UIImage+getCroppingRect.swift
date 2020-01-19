//
//  UIImage+getCroppingRect.swift
//  SuperPaint
//
//  Created by Stanislav on 12/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension UIImage
{
	func getCroppingRect(from imageRect: CGRect, to cropRect: CGRect, sourceSize: CGSize? = nil) -> CGRect {
		let widthScale = (sourceSize?.width ?? self.size.width) / imageRect.width
		let heightScale = (sourceSize?.height ?? self.size.height) / imageRect.height
		var targetCropRect = cropRect
		targetCropRect.origin.x = (targetCropRect.origin.x - imageRect.origin.x) * widthScale
		targetCropRect.origin.y = (round(imageRect.origin.y + imageRect.height) -
			round(targetCropRect.origin.y + targetCropRect.height)) * heightScale
		targetCropRect.size.width *= widthScale
		targetCropRect.size.height *= heightScale

		return targetCropRect
	}
}
