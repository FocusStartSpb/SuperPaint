//
//  UIImage+setFilter.swift
//  SuperPaint
//
//  Created by Stanislav on 23/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

extension UIImage
{
	func setFilter(_ filter: Filter?,
				   parameter: FilterParameter? = nil,
				   newValue: NSNumber? = nil,
				   completion: @escaping (UIImage) -> Void) {
		guard let filter = filter else { return }
		let context = CIContext(options: nil)
		let ciFilter = CIFilter(name: filter.code)
		let ciImage = CIImage(image: self)
		ciFilter?.setValue(ciImage, forKey: kCIInputImageKey)
		if let parameter = parameter, let value = newValue {
			ciFilter?.setValue(value, forKey: parameter.code)
		}
		guard let ciOutputImage = ciFilter?.outputImage else { return }
		guard let cgImage = context.createCGImage(ciOutputImage, from: ciOutputImage.extent)  else { return }
		completion(UIImage(cgImage: cgImage))
	}
}
