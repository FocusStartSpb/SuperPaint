//
//  ImagesCollectionRouter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImagesCollectionRouter
{
	weak var view: IImagesCollectionViewController?
	private let factory: ModuleFactory

	init(factory: ModuleFactory) {
		self.factory = factory
	}

	func inject(view: IImagesCollectionViewController) {
		self.view = view
	}
}

extension ImagesCollectionRouter: IImagesCollectionRouter
{
	func pushEditorModule(id: String, image: UIImage, isNewImage: Bool) {
		let vc = self.factory.createImageEditorModule(id: id, image: image, isNewImage: isNewImage)
		self.view?.navController?.pushViewController(vc, animated: true)
	}

	func pushWebSearchModule() {
		let vc = self.factory.createWebSearchModule()
		self.view?.navController?.pushViewController(vc, animated: true)
	}
}
