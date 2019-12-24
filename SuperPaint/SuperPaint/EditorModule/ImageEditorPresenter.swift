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
	let filtersList: [Filter]
	var filteredPreviews: [UIImage] = []
	private var imageStack = ImagesStack()
	private let router: IImageEditorRouter
	private let repository: IDatabaseRepository
	private weak var view: IImageEditorViewController?
	private var image: UIImage
	private var previousAppliedFilterIndex: Int?

	init(router: IImageEditorRouter, repository: IDatabaseRepository, image: UIImage) {
		self.router = router
		self.repository = repository
		self.image = image
		filtersList = FiltersList.allCases.map{ $0.getFilter() }
	}
}

extension ImageEditorPresenter: IImageEditorPresenter
{
	func undoAction() {
		if let lastImage = imageStack.pop() {
			view?.setImage(image: lastImage)
		}
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
		previousAppliedFilterIndex = nil
	}

	func applyFilter(image: UIImage, filterIndex: Int) {
		//Если фильтр уже применен не применяем снова
		var currentFilterAlreadyApplied = false
		if let previousIndex = previousAppliedFilterIndex, previousIndex == filterIndex {
			currentFilterAlreadyApplied = true
		}
		if currentFilterAlreadyApplied == false {
			view?.startSpinner()
			imageStack.clear()
			imageStack.push(image)
			view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
			let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInitiated, attributes: .concurrent)
			filterQueue.async { [weak self] in
				image.setFilter(self?.filtersList[filterIndex]) { filteredImage in
					DispatchQueue.main.async {
						self?.view?.setImage(image: filteredImage)
						self?.view?.stopSpinner()
						self?.previousAppliedFilterIndex = filterIndex
					}
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
