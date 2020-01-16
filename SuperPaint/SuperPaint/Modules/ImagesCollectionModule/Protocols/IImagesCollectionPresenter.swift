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
	func saveNewImage(newImageModel: ImageModel)
	func updateImage(imageModel: ImageModel)
	func deleteImages(_ indexes: [IndexPath])
	func getImages() -> [ImageModel]
	func getNumberOfImages() -> Int
	func getImageModelAt(index: Int, completion: (ImageModel) -> Void)
	func getImage(index: Int, completion: @escaping (UIImage) -> Void)
	func onCellPressed(id: String, image: UIImage, isNewImage: Bool)
	func pushWebSearchModule()
}
