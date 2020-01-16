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
	private var images: [UIImage] = []
	private let dispatchQueue = DispatchQueue(label: "resizeImage", qos: .userInteractive)

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
				for imageModel in imagesResult {
					self.getImage(imageModel: imageModel) { image in
						guard let image = image else { return }
						self.images.append(image)
					}
				}
				self.imagesCollectionViewController?.reloadView()
			case .failure(let error):
				assertionFailure(error.localizedDescription)
			}
		}
	}

	func saveNewImage(newImageModel: ImageModel) {
		self.imageModels.append(newImageModel)
		self.getImage(imageModel: newImageModel) { image in
			guard let image = image else { return }
			self.images.append(image)
		}
		self.imagesCollectionViewController?.reloadView()
	}

	func updateImage(imageModel: ImageModel) {
		for (index, model) in self.imageModels.enumerated() where model.id == imageModel.id {
			self.imageModels[index] = imageModel
			self.getImage(imageModel: imageModel) { image in
				guard let image = image else { return }
				self.images[index] = image
			}
		}
		self.imagesCollectionViewController?.reloadView()
	}

	func deleteImages(_ indexes: [IndexPath]) {
		var selectedImages: [ImageModel] = []
		indexes.forEach { indexPath in
			selectedImages.append(self.imageModels[indexPath.row - UIConstants.firstCell])
		}
		let imagesIds = selectedImages.map { return $0.id }
		let imagesAfterDeletion = self.imageModels.filter { imageModel -> Bool in
			return imagesIds.contains(imageModel.id) == false
		}
		self.imageModels = imagesAfterDeletion
		self.repository.deleteImages(selectedImages)
	}

	func getImages() -> [ImageModel] {
		return self.imageModels
	}

	func getNumberOfImages() -> Int {
		return self.imageModels.count + UIConstants.firstCell
	}

	func getImageModelAt(index: Int, completion: (ImageModel) -> Void) {
		completion(self.imageModels[index])
	}

	func getImage(imageModel: ImageModel, completion: @escaping (UIImage?) -> Void) {
		if let data = imageModel.imageData as Data?, let image = UIImage(data: data) {
			image.resizeImage(newHeight: UIConstants.imageCellQuality) { resizedImage in
				completion(resizedImage)
			}
		}
	}

	func getImage(index: Int, completion: @escaping (UIImage) -> Void) {
		completion(self.images[index])
	}

	func onCellPressed(id: String, image: UIImage, isNewImage: Bool) {
		self.imagesCollectionRouter.pushEditorModule(id: id, image: image, isNewImage: isNewImage)
	}

	func pushWebSearchModule() {
		self.imagesCollectionRouter.pushWebSearchModule()
	}
}
