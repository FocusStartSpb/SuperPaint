//
//  ModuleFactory.swift
//  SuperPaint
//
//  Created by Stanislav on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

struct ModuleFactory
{
	private let networkRepository: INetworkRepository
	private let databaseRepository: IDatabaseRepository

	init() {
		self.networkRepository = NetworkRepository()
		self.databaseRepository = DatabaseRepository(imagesManager: CDImageModelManager())
	}

	func createNavigationController() -> UIViewController {
		let imagesCollectionModule = createImagesCollectionModule()
		let navigationController = UINavigationController(rootViewController: imagesCollectionModule)
		return  navigationController
	}

	func createImagesCollectionModule() -> UIViewController {
		let router = ImagesCollectionRouter(factory: self)
		let presenter = ImagesCollectionPresenter(router: router, repository: self.databaseRepository)
		let view = ImagesCollectionViewController(presenter: presenter)
		presenter.inject(view: view)
		router.inject(view: view)
		return view
	}

	func createImageEditorModule(id: String, image: UIImage, isNewImage: Bool) -> UIViewController {
		let router = ImageEditorRouter(factory: self)
		let presenter = ImageEditorPresenter(router: router,
											 repository: self.databaseRepository,
											 id: id, image: image,
											 isNewImage: isNewImage)
		let view = ImageEditorViewController(presenter: presenter)
		presenter.inject(view: view)
		router.inject(view: view)
		return view
	}
}
