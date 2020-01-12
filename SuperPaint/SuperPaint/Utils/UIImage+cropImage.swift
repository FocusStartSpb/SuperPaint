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
	func cropImage(to cropRect: CGRect) -> UIImage? {
		guard let croppedCGImage = self.cgImage?.cropping(to: cropRect) else { return nil }
		return UIImage(cgImage: croppedCGImage)
	}
}
