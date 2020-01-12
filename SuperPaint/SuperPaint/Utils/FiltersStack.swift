//
//  FiltersStack.swift
//  SuperPaint
//
//  Created by Stanislav on 09/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import Foundation

struct FiltersStack
{
	private var filtersStack: [(instrumenCode: String, parameterCode: String, parameterValue: NSNumber)] = []

	mutating func push(_ filter: (instrumenCode: String, parameterCode: String, parameterValue: NSNumber)) {
		filtersStack.append(filter)
	}

	mutating func pop() -> (instrumenCode: String, parameterCode: String, parameterValue: NSNumber)? {
		if filtersStack.isEmpty {
			return nil
		}
		else {
			return filtersStack.removeLast()
		}
	}

	mutating func clear() {
		filtersStack = []
	}
}
