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
	let filtersList: [Filter]
	private weak var view: IImageEditorViewController?
	private var image: UIImage
	var filteredPreviews: [UIImage] = []

	init(router: IImageEditorRouter, repository: IDatabaseRepository, image: UIImage) {
		self.router = router
		self.repository = repository
		self.image = image
		filtersList = FiltersList.allCases.map{ $0.getFilter() }
	}
}

extension ImageEditorPresenter: IImageEditorPresenter
{
	func applyFilter(image: UIImage, filterIndex: Int, completion: @escaping (UIImage) -> Void) {
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInitiated, attributes: .concurrent)
		filterQueue.async { [weak self] in
			image.setFilter(self?.filtersList[filterIndex]) { filteredImage in
				DispatchQueue.main.async {
					completion(filteredImage)
				}
			}
		}
	}

	var currentImage: UIImage {
		return image
	}

	var numberOfPreviews: Int {
		return filteredPreviews.count
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
		guard let preview = image.resizeImage(to: 100) else { return }
		filtersList.forEach{ preview.setFilter($0) { filteredImage in self.filteredPreviews.append(filteredImage) }
		}
	}
}
