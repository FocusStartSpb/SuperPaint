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
	let actionType: ActionType
	var parameters: [FilterParameter]

	init(with name: String, code: String, actionType: ActionType, parameters: [FilterParameter] = []) {
		self.name = name
		self.code = code
		self.actionType = actionType
		self.parameters = parameters
	}

	mutating func setValueForParameter(parameterCode: String, newValue: Any) {
		for index in parameters.indices where parameters[index].code == parameterCode {
			parameters[index].currentValue = newValue
		}
	}
}
