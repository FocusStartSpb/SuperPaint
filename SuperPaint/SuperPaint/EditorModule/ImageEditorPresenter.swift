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
	private var image: UIImage
	var filteredImages: [UIImage] = []

	init(router: IImageEditorRouter, repository: IDatabaseRepository, image: UIImage) {
		self.router = router
		self.repository = repository
		self.image = image
	}
}

extension ImageEditorPresenter: IImageEditorPresenter
{
	var currentImage: UIImage {
		return image
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
}

private extension ImageEditorPresenter
{
	func createFilteredImageCollection() {
		for _ in 0..<10 {
			filteredImages.append(image)
		}
	}
}
