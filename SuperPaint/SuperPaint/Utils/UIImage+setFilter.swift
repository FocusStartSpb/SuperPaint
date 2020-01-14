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
				   completion: @escaping (UIImage) -> Void) {
		guard let filter = filter else { return }
		let context = CIContext(options: nil)
		let ciFilter = CIFilter(name: filter.code)
		let ciImage = CIImage(image: self)
		ciFilter?.setValue(ciImage, forKey: kCIInputImageKey)
		filter.parameters.forEach{ parameter in
			ciFilter?.setValue(parameter.currentValue, forKey: parameter.code)
		}
		guard let ciOutputImage = ciFilter?.outputImage else { return }
		guard let rect = ciImage?.extent else { return }

		guard let cgImage = context.createCGImage(ciOutputImage, from: rect)  else { return }
		completion(UIImage(cgImage: cgImage))
	}

	func setFiltersList(filtersList: [Filter]?,
						completion: @escaping (UIImage) -> Void) {
		guard let filtersList = filtersList else { return }
		let context = CIContext(options: nil)
		var ciImage = CIImage(image: self)
		guard let rect = ciImage?.extent else { return }
		filtersList.forEach { filter in
			filter.parameters.forEach { parameter in
				if parameter.currentValue != parameter.defaultValue {
					let ciFilter = CIFilter(name: filter.code)
					ciFilter?.setValue(ciImage, forKey: kCIInputImageKey)
					ciFilter?.setValue(parameter.currentValue, forKey: parameter.code)
					ciImage = ciFilter?.outputImage
				}
			}
		}
		guard let outputImage = ciImage else { return }
		guard let cgImage = context.createCGImage(outputImage, from: rect)  else { return }
		completion(UIImage(cgImage: cgImage))
	}
}
