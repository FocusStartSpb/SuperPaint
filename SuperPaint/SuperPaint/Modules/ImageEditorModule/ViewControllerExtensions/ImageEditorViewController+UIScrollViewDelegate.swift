//
//  ImageEditorViewController+UIScrollViewDelegate.swift
//  SuperPaint
//
//  Created by Stanislav on 13/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension ImageEditorViewController: UIScrollViewDelegate
{
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		guard cropMode == false else { return nil }
		return imageView
	}
}
