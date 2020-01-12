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
	var instrumentsList: [Filter]
	var filteredPreviews: [UIImage] = []
	private var imageStack = ImagesStack()
	private var filtersStack = FiltersStack()
	private let router: IImageEditorRouter
	private let repository: IDatabaseRepository
	private weak var view: IImageEditorViewController?
	private let id: String
	private let isNewImage: Bool
	private var sourceImage: UIImage
	private var editingImage: UIImage
	private var previousAppliedFilterIndex: Int?
	private var previousAppliedInstrumentIndex: Int?
	private var currentApplyingFilterIndex: Int?

	init(router: IImageEditorRouter, repository: IDatabaseRepository, id: String, image: UIImage, isNewImage: Bool) {
		self.router = router
		self.repository = repository
		self.id = id
		self.sourceImage = image
		self.editingImage = image
		filtersList = FiltersList.allCases.filter{ $0.getFilter().parameters.isEmpty }.map{ $0.getFilter() }
		instrumentsList = FiltersList.allCases.filter{ $0.getFilter().parameters.isEmpty == false }.map{ $0.getFilter() }
		self.isNewImage = isNewImage
	}
}
// MARK: - IImageEditorPresenter
extension ImageEditorPresenter: IImageEditorPresenter
{
	func undoAction() {
		if let lastImage = imageStack.pop() {
			self.editingImage = lastImage
			view?.setImage(image: lastImage)
		}
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
		previousAppliedFilterIndex = nil
		if let lastChangedParameter = filtersStack.pop() {
			for (index, instrument) in instrumentsList.enumerated() where instrument.code == lastChangedParameter.instrumenCode {
				for (indexP, parameter) in instrument.parameters.enumerated()
					where parameter.code == lastChangedParameter.parameterCode {
					instrumentsList[index].parameters[indexP].currentValue = lastChangedParameter.parameterValue
				}
			}
			view?.refreshSlidersValues()
		}
	}
// MARK: - Фильтр
	func applyFilter(filterIndex: Int) {
		currentApplyingFilterIndex = filterIndex
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
			let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
			filterQueue.async { [weak self] in
				self?.sourceImage.setFilter(self?.filtersList[filterIndex]) { filteredImage in
					self?.editingImage = filteredImage
					DispatchQueue.main.async {
						//применять будем только последний нажатый фильтр
						if let currentIndex = self?.currentApplyingFilterIndex, currentIndex == filterIndex {
							self?.view?.setImage(image: filteredImage)
							self?.view?.stopSpinner()
							self?.previousAppliedFilterIndex = filterIndex
						}
					}
				}
			}
		}
	}
// MARK: - Инструмент
	func applyInstrument(instrument: Filter, instrumentIndex: Int, parameter: FilterParameter, newValue: Float) {
		view?.startSpinner()
		imageStack.push(self.editingImage)
//Запомним текущее значение параметра и сложим в стэк
		for param in instrumentsList[instrumentIndex].parameters where param.code == parameter.code {
			filtersStack.push((instrumentsList[instrumentIndex].code, param.code, param.currentValue))
		}
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
//Если применяем инструмент повторно, берем исходную картинку, иначе применям на текущую
		var currentInstrumentAlreadyApplied = false
		if let previousIndex = previousAppliedInstrumentIndex, previousIndex == instrumentIndex {
			currentInstrumentAlreadyApplied = true
		}
		instrumentsList[instrumentIndex].setValueForParameter(parameterCode: parameter.code, newValue: parameter.currentValue)
		let instrumentQueue = DispatchQueue(label: "InstrumentQueue", qos: .userInteractive, attributes: .concurrent)
		instrumentQueue.async { [weak self] in
			let imageForApply = currentInstrumentAlreadyApplied ? self?.sourceImage : self?.editingImage
			imageForApply?.setFilter(self?.instrumentsList[instrumentIndex]) { filteredImage in
				self?.editingImage = filteredImage
				DispatchQueue.main.async {
					self?.view?.setImage(image: filteredImage)
					self?.view?.stopSpinner()
					self?.previousAppliedInstrumentIndex = instrumentIndex
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

	var numberOfInstruments: Int {
		return instrumentsList.count
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

	func getCurrentInstrumentParameters(instrumentIndex: Int) -> [FilterParameter] {
		return instrumentsList[instrumentIndex].parameters
	}

	func saveImage() {
		guard let imageData = editingImage.pngData() else { return }
		if isNewImage {
			self.repository.saveImage(id: id, data: imageData as NSData)
		}
		else {
			self.repository.updateImage(id: id, data: imageData as NSData)
		}
		self.moveToMain()
	}

	func moveBack() {
		self.router.moveBack()
	}

	func moveToMain() {
		self.router.moveToMain()
	}

	func cropImage(cropRect: CGRect) {
		guard let croppedImage = editingImage.cropImage(to: cropRect) else { return }
		imageStack.push(self.editingImage)
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
		editingImage = croppedImage
		view?.setImage(image: editingImage)
	}
}
// MARK: - private extension
private extension ImageEditorPresenter
{
	func createFilteredImageCollection() {
		guard let preview = sourceImage.resizeImage(to: UIConstants.collectionViewCellWidth) else { return }
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
		filterQueue.async { [weak self] in
			self?.filtersList.forEach{
				preview.setFilter($0) { filteredImage in self?.filteredPreviews.append(filteredImage) }
			}
			DispatchQueue.main.async {
				self?.view?.refreshButtonsState(imagesStackIsEmpty: self?.imageStack.isEmpty ?? true)
				self?.view?.reloadFilterPreviews()
			}
		}
	}
}
