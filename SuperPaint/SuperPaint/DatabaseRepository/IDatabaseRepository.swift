//
//  IDatabaseRepository.swift
//  SuperPaint
//
//  Created by Иван Медведев on 23/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

protocol IDatabaseRepository: AnyObject
{
	var imagesManager: ICDImageModelManager { get }

	func loadImages(completion: (ImagesResult) -> Void)
	func saveImage(id: String, data imageData: NSData)
	func updateImage(id: String, data imageData: NSData)
	func deleteImages(_ images: [ImageModel])
	func saveContext()
}
