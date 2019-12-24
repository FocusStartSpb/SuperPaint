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
	private let id: String
	private var sourceImage: UIImage
	private var editingImage: UIImage
	private var previousAppliedFilterIndex: Int?
	private let isNewImage: Bool

	init(router: IImageEditorRouter, repository: IDatabaseRepository, id: String, image: UIImage, isNewImage: Bool) {
		self.router = router
		self.repository = repository
		self.id = id
		self.sourceImage = image
		self.editingImage = image
		filtersList = FiltersList.allCases.map{ $0.getFilter() }
		self.isNewImage = isNewImage
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

	func applyFilter(filterIndex: Int) {
		//Если фильтр уже применен не применяем снова
		var currentFilterAlreadyApplied = false
		if let previousIndex = previousAppliedFilterIndex, previousIndex == filterIndex {
			currentFilterAlreadyApplied = true
		}
		if currentFilterAlreadyApplied == false {
			view?.startSpinner()
			imageStack.clear()
			imageStack.push(sourceImage)
			view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
			let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInitiated, attributes: .concurrent)
			filterQueue.async { [weak self] in
				self?.sourceImage.setFilter(self?.filtersList[filterIndex]) { filteredImage in
					DispatchQueue.main.async {
						self?.editingImage = filteredImage
						self?.view?.setImage(image: filteredImage)
						self?.view?.stopSpinner()
						self?.previousAppliedFilterIndex = filterIndex
					}
				}
			}
		}
	}

	var currentId: String {
		return id
	}

	var currentImage: UIImage {
		return sourceImage
	}

	var numberOfPreviews: Int {
		return filteredPreviews.count
	}

	var newImage: Bool {
		return isNewImage
	}

	var imageEdited: Bool {
		return sourceImage != editingImage
	}

	func triggerViewReadyEvent() {
		createFilteredImageCollection()
	}

	func inject(view: IImageEditorViewController) {
		self.view = view
	}

	func saveImage() {
		guard let imageData = editingImage.pngData() else { return }
		if isNewImage {
			self.repository.saveImage(id: id, data: imageData as NSData)
		}
		else {
			self.repository.updateImage(id: id, data: imageData as NSData)
		}
		moveBack()
	}

	func moveBack() {
		self.router.moveBack()
	}
}

private extension ImageEditorPresenter
{
	func createFilteredImageCollection() {
		guard let preview = sourceImage.resizeImage(to: 100) else { return }
		filtersList.forEach{ preview.setFilter($0) { filteredImage in self.filteredPreviews.append(filteredImage) }
		}
	}
}
