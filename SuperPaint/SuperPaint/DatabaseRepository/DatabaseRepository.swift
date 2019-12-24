//
//  DatabaseRepository.swift
//  SuperPaint
//
//  Created by Иван Медведев on 23/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

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
				completion(.success(imagesResult))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func saveImage(_ image: ImageModel) {
		self.imagesManager.saveImage(image)
	}

	func deleteImages(_ images: [ImageModel]) {
		self.imagesManager.deleteImages(images)
	}

	func saveContext() {
		self.imagesManager.saveContext()
	}
}
