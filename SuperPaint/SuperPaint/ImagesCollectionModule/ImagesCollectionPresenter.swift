//
//  ImagesCollectionPresenter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImagesCollectionPresenter
{
	private let imagesCollectionRouter: IImagesCollectionRouter
	private let repository: IDatabaseRepository
	private weak var imagesCollectionViewController: IImagesCollectionViewController?

	private var imageModels: [ImageModel] = []

	init(router: IImagesCollectionRouter, repository: IDatabaseRepository) {
		self.imagesCollectionRouter = router
		self.repository = repository
	}

	func inject(view: IImagesCollectionViewController) {
		self.imagesCollectionViewController = view
	}
}

extension ImagesCollectionPresenter: IImagesCollectionPresenter
{
	func loadImages() {
		self.repository.loadImages { imagesResult in
			switch imagesResult {
			case .success(let imagesResult):
				self.imageModels = imagesResult
				self.imagesCollectionViewController?.reloadView()
			case .failure(let error):
				assertionFailure(error.localizedDescription)
			}
		}
	}

	func saveImage(id: String, data: NSData) {
		self.repository.saveImage(id: id, data: data)
	}

	func deleteImages(_ images: [ImageModel]) {
		let imagesIds = images.map { return $0.id }
		let imagesAfterDeletion = self.imageModels.filter { imageModel -> Bool in
			return imagesIds.contains(imageModel.id) == false
		}
		self.imageModels = imagesAfterDeletion
		self.repository.deleteImages(images)
	}

	func getImages() -> [ImageModel] {
		return self.imageModels
	}

	func getNumberOfImages() -> Int {
		return self.imageModels.count + 1 // 1 - Первая ячейка
	}

	func getImageModelAt(index: Int) -> ImageModel {
		return self.imageModels[index]
	}

	func onCellPressed(id: String, data: NSData, isNewImage: Bool) {
		self.imagesCollectionRouter.pushEditorModule(id: id, data: data, isNewImage: isNewImage)
	}
}
