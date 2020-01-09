//
//  Filter.swift
//  SuperPaint
//
//  Created by Stanislav on 22/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

struct Filter
{
	let name: String
	let code: String
	var parameters: [FilterParameter]

	init(with name: String, code: String, parameters: [FilterParameter] = []) {
		self.name = name
		self.code = code
		self.parameters = parameters
	}

	mutating func setValueForParameter(parameter code: String, newValue: NSNumber) {
		for index in parameters.indices where parameters[index].code == code {
			parameters[index].currentValue = newValue
		}
	}
}
