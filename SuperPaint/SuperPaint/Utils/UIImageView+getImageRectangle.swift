//
//  UIImageView+getImageRectangle.swift
//  SuperPaint
//
//  Created by Stanislav on 11/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImageView
{
	func getImageRect() -> CGRect {
		guard let imageSize = self.image?.size else { return CGRect.zero }
		let imageRect = AVMakeRect(aspectRatio: imageSize, insideRect: self.bounds)
		return imageRect
	}
}
