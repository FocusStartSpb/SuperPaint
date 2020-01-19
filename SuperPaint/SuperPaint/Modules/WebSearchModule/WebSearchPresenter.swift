//
//  WebSearchPresenter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 08/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

final class WebSearchPresenter
{
	private let router: IWebSearchRouter
	private let repository: INetworkRepository
	private weak var view: IWebSearchViewController?

	private var images = [UIImage]()
	private var totalPages = 0

	init(router: IWebSearchRouter, repository: INetworkRepository) {
		self.router = router
		self.repository = repository
	}

	func inject(view: IWebSearchViewController) {
		self.view = view
	}
}

extension WebSearchPresenter: IWebSearchPresenter
{
	func loadImages(withSearchText text: String?, page: Int) {
		self.repository.loadImages(withSearchText: text, page: page) { unsplashImagesResult in
			switch unsplashImagesResult {
			case .success(let result):
				DispatchQueue.main.async {
					if result.query == self.view?.searchBarText {
						result.images.forEach { self.images.append($0) }
						self.totalPages = result.totalPages
						self.view?.reloadView(itemsCount: self.images.count)
					}
				}
			case .failure(let error):
				assertionFailure(error.localizedDescription)
			}
		}
	}

	func clearImages() {
		self.images.removeAll()
	}

	func getNumberOfImages() -> Int {
		return self.images.count
	}

	func getTotalPages() -> Int {
		return self.totalPages
	}

	func getImageAtIndex(index: Int) -> UIImage {
		return self.images[index]
	}

	func onCellPressed(image: UIImage) {
		self.router.pushEditorModule(image: image)
	}
}
