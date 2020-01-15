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
						isFilter: Bool,
						 completion: @escaping (CIImage, CGRect) -> Void) {
		guard let filtersList = filtersList else { return }
		var ciImage = CIImage(image: self)
		guard let ciRect = ciImage?.extent else { return }
		var filters: [CIFilter?] = []
		filtersList.forEach { filter in
			var parameters: [String: Any] = [:]
			filter.parameters.forEach { parameter in
				if parameter.currentValue != parameter.defaultValue {
					parameters[parameter.code] = parameter.currentValue
				}
			}
			if parameters.isEmpty == false || isFilter {
				filters.append(CIFilter(name: filter.code, parameters: parameters))
			}
		}
		//применим фильтры
		filters.compactMap{ $0 }.forEach { filter in
			filter.setValue(ciImage, forKey: kCIInputImageKey)
			ciImage = filter.outputImage
		}
		guard let outputImage = ciImage else { return }
		completion(outputImage, ciRect)
	}
}
