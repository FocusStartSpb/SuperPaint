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
	func setFiltersList(filtersList: [Filter]?,
						actionType: ActionType,
						 completion: @escaping (CIImage, CGRect) -> Void) {
		guard let filtersList = filtersList else { return }
		var ciImage = CIImage(image: self)
		guard let sourceCIRect = ciImage?.extent else { return }
		var filters: [CIFilter?] = []
		filtersList.forEach { filter in
			var parameters: [String: Any] = [:]
			filter.parameters.forEach { parameter in
				if let currentValue = parameter.currentValue as? NSNumber,
					let defaultValue = parameter.defaultValue as? NSNumber,
					currentValue != defaultValue {
						parameters[parameter.code] = parameter.currentValue
					}
				if let currentValue = parameter.currentValue as? CIVector,
				let defaultValue = parameter.defaultValue as? CIVector,
				currentValue != defaultValue {
					parameters[parameter.code] = parameter.currentValue
				}
			}
			if parameters.isEmpty == false || filter.actionType == .filter {
				filters.append(CIFilter(name: filter.code, parameters: parameters))
			}
		}
		//применим фильтры
		filters.compactMap{ $0 }.forEach { filter in
			filter.setValue(ciImage, forKey: kCIInputImageKey)
			ciImage = filter.outputImage
		}
		guard let outputImage = ciImage else { return }
		let rect = (actionType == .crop) ? outputImage.extent : sourceCIRect
		completion(outputImage, rect)
	}
}
