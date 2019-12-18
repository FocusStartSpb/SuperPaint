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
	let repository: IRepository

	init(repository: IRepository) {
		self.repository = repository
	}

	func createNavigationController() -> UIViewController {
		let imagesCollectionModule = createImagesCollectionModule()
		let navigationController = UINavigationController(rootViewController: imagesCollectionModule)
		return  navigationController
	}

	func createImagesCollectionModule() -> UIViewController {
		let router = ImagesCollectionRouter()
		let presenter = ImagesCollectionPresenter(router: router, repository: repository)
		let view = ImagesCollectionViewController(presenter: presenter)
		presenter.inject(view: view)
		router.inject(view: view)
		return viewController
	}
}
