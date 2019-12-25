//
//  IImagesCollectionPresenter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

protocol IImagesCollectionPresenter: AnyObject
{
	func loadImages()
	func saveImage(id: String, data: NSData)
	func deleteImages(_ indexes: [IndexPath])
	func getImages() -> [ImageModel]
	func getNumberOfImages() -> Int
	func getImageModelAt(index: Int) -> ImageModel
	func onCellPressed(id: String, data: NSData, isNewImage: Bool)
}
