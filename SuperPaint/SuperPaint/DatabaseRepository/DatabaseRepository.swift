//
//  DatabaseRepository.swift
//  SuperPaint
//
//  Created by Иван Медведев on 23/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation
import CoreData

final class DatabaseRepository
{
	let imagesManager: ICDImageModelManager

	init(imagesManager: ICDImageModelManager) {
		self.imagesManager = imagesManager
	}
}

extension DatabaseRepository: IDatabaseRepository
{
	func loadImages(completion: (ImagesResult) -> Void) {
		self.imagesManager.loadImages { imagesResult in
			switch imagesResult {
			case .success(let imagesResult):
				completion(.success(imagesResult.reversed()))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func saveImage(id: String, data imageData: NSData, isNewImage: Bool, completion: (ImageModel) -> Void) {
		if isNewImage {
			self.imagesManager.saveImage(id: id, data: imageData) { imageModel in
				completion(imageModel)
			}
		}
		else {
			self.imagesManager.updateImage(id: id, data: imageData) { imageModel in
				completion(imageModel)
			}
		}
	}

//	func updateImage(id: String, data imageData: NSData, completion: (ImageModel) -> Void) {
//		self.imagesManager.updateImage(id: id, data: imageData) { imageModel in
//			completion(imageModel)
//		}
//	}

	func deleteImages(_ images: [ImageModel]) {
		self.imagesManager.deleteImages(images)
	}

	func saveContext() {
		self.imagesManager.saveContext()
	}
}
