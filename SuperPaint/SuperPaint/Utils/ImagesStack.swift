//
//  ImagesStack.swift
//  SuperPaint
//
//  Created by Stanislav on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

struct ImagesStack
{
	private var imagesStack: [UIImage] = []
	var isEmpty: Bool {
		return imagesStack.count == 0
	}

	mutating func push(_ image: UIImage) {
		imagesStack.append(image)
	}

	mutating func pop() -> UIImage? {
		if imagesStack.isEmpty {
			return nil
		}
		else {
			return imagesStack.removeLast()
		}
	}

	mutating func clear() {
		imagesStack = []
	}
}
