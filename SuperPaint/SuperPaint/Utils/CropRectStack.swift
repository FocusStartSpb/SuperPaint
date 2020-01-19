//
//  CropRectStack.swift
//  SuperPaint
//
//  Created by Stanislav on 18/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

struct CropRectStack
{
	private var cropRectStack: [CGRect] = []
	var isEmpty: Bool {
		return cropRectStack.count == 0
	}

	mutating func push(_ rect: CGRect?) {
		if let rect = rect {
			cropRectStack.append(rect)
		}
	}

	mutating func pop() -> CGRect? {
		if cropRectStack.isEmpty {
			return nil
		}
		else {
			return cropRectStack.removeLast()
		}
	}

	mutating func clear() {
		cropRectStack = []
	}
}
