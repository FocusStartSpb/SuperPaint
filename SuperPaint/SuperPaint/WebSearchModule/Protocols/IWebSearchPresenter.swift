//
//  IWebSearchPresenter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 08/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

protocol IWebSearchPresenter: AnyObject
{
	func loadImages(withSearchText text: String?, page: Int)
	func clearImages()
	func getNumberOfImages() -> Int
	func getTotalPages() -> Int
	func getImageAtIndex(index: Int) -> UIImage
	func onCellPressed(image: UIImage)
}
