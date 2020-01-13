//
//  FilterParameter.swift
//  SuperPaint
//
//  Created by Stanislav on 05/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import Foundation

struct FilterParameter
{
	let name: String
	let code: String
	let defaultValue: NSNumber
	let minValue: NSNumber
	let maxValue: NSNumber
	var currentValue: NSNumber

	init(name: String,
		 code: String,
		 defaultValue: NSNumber,
		 minValue: NSNumber,
		 maxValue: NSNumber) {
		self.name = name
		self.code = code
		self.defaultValue = defaultValue
		self.minValue = minValue
		self.maxValue = maxValue
		self.currentValue = self.defaultValue
	}
}
