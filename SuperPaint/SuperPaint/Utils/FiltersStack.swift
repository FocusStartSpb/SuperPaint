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
	private var filtersStack: [[Filter]] = []

	mutating func push(_ filter: [Filter]) {
		filtersStack.append(filter)
	}

	mutating func pop() -> [Filter]? {
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

	func getLastFilterByType(actionType: ActionType) -> Filter? {
		for index in (0..<filtersStack.count).reversed() {
			let zeroElement = filtersStack[index][0]
			if zeroElement.actionType == actionType {
				return zeroElement
			}
		}
		return nil
	}
}
