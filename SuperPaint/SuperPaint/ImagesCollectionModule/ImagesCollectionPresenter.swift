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
	private let repository: IRepository
	private weak var imagesCollectionViewController: IImagesCollectionViewController?

	init(router: IImagesCollectionRouter, repository: IRepository) {
		self.imagesCollectionRouter = router
		self.repository = repository
	}

	func inject(view: IImagesCollectionViewController) {
		self.imagesCollectionViewController = view
	}
}

extension ImagesCollectionPresenter: IImagesCollectionPresenter
{
	func onCellPressed(with image: UIImage) {
		self.imagesCollectionRouter.pushEditorModule(with: image)
	}
}
