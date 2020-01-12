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
	private let webSearchRouter: IWebSearchRouter
	private let repository: INetworkRepository
	private weak var webSearchViewController: IWebSearchViewController?

	private var images = [UIImage]()
	private var totalPages = 0

	init(router: IWebSearchRouter, repository: INetworkRepository) {
		self.webSearchRouter = router
		self.repository = repository
	}

	func inject(view: IWebSearchViewController) {
		self.webSearchViewController = view
	}
}

extension WebSearchPresenter: IWebSearchPresenter
{
	func loadImages(withSearchText text: String?, page: Int) {
		self.repository.loadImages(withSearchText: text, page: page) { unsplashImagesResult in
			switch unsplashImagesResult {
			case .success(let result):
				DispatchQueue.main.async {
					if result.query == self.webSearchViewController?.searchBarText {
						result.images.forEach { self.images.append($0) }
						self.totalPages = result.totalPages
						self.webSearchViewController?.reloadView(itemsCount: self.images.count)
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
		self.webSearchRouter.pushEditorModule(image: image)
	}
}
