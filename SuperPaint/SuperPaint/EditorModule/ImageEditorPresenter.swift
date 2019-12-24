//
//  ImageEditorPresenter.swift
//  SuperPaint
//
//  Created by Stanislav on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImageEditorPresenter
{
	private let router: IImageEditorRouter
	private let repository: IDatabaseRepository
	private weak var view: IImageEditorViewController?
	private let id: String
	private var image: UIImage
	private let isNewImage: Bool
	var filteredImages: [UIImage] = []

	init(router: IImageEditorRouter, repository: IDatabaseRepository, id: String, image: UIImage, isNewImage: Bool) {
		self.router = router
		self.repository = repository
		self.id = id
		self.image = image
		self.isNewImage = isNewImage
	}
}

extension ImageEditorPresenter: IImageEditorPresenter
{
	var currentId: String {
		return id
	}

	var currentImage: UIImage {
		return image
	}

	var newImage: Bool {
		return isNewImage
	}

	var numberOfFilters: Int {
		return filteredImages.count
	}

	func triggerViewReadyEvent() {
		createFilteredImageCollection()
	}

	func inject(view: IImageEditorViewController) {
		self.view = view
	}

	func saveImage(id: String, data: NSData, isNewImage: Bool) {
		if isNewImage {
			self.repository.saveImage(id: id, data: data)
		}
		else {
			self.repository.updateImage(id: id, data: data)
		}
	}

	func moveBack() {
		self.router.moveBack()
	}
}

private extension ImageEditorPresenter
{
	func createFilteredImageCollection() {
		for _ in 0..<10 {
			filteredImages.append(image)
		}
	}
}
