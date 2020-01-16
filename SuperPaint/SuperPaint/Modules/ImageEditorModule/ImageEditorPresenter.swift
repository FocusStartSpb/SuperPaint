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
	private let imagesState = ImagesState()
	private let id: String
	private let isNewImage: Bool
	private var previousAppliedFilterIndex: Int?
	private var previousAppliedInstrumentIndex: Int?
	private var currentApplyingFilterIndex: Int?
	private let context = CIContext(options: nil)
	private var lastApplyingFilter: Filter?

	init(router: IImageEditorRouter, repository: IDatabaseRepository, id: String, image: UIImage, isNewImage: Bool) {
		self.router = router
		self.repository = repository
		self.id = id
		self.imagesState.sourceImage = image
		filtersList = FiltersList.allCases.filter{ $0.getFilter().parameters.isEmpty }.map{ $0.getFilter() }
		instrumentsList = FiltersList.allCases.filter{ $0.getFilter().parameters.isEmpty == false }.map{ $0.getFilter() }
		self.isNewImage = isNewImage
		guard let resizedImage = image.resizeImage(to: UIConstants.editorImageDimension) else { return }
		self.imagesState.editingImage = resizedImage
		self.imagesState.instrumentSourceImage = resizedImage
		self.imagesState.filterSourceImage = resizedImage
	}
}
// MARK: - IImageEditorPresenter
extension ImageEditorPresenter: IImageEditorPresenter
{
	func undoAction() {
		if let lastImage = imageStack.pop() {
			self.imagesState.editingImage = lastImage
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
		let isFilter = true
		currentApplyingFilterIndex = filterIndex
		//Если фильтр уже применен не применяем снова
		var currentFilterAlreadyApplied = false
		if let previousIndex = previousAppliedFilterIndex, previousIndex == filterIndex {
			currentFilterAlreadyApplied = true
		}
		let filter = filtersList[filterIndex]
		if currentFilterAlreadyApplied == false {
			filterApplyingPreparing(isFilter: isFilter)
			let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
			filterQueue.async { [weak self] in
				self?.imagesState.filterSourceImage.setFiltersList(filtersList: [filter],
																   isFilter: isFilter) { ciImage, rect in
					//применять будем только последний нажатый фильтр
					if let currentIndex = self?.currentApplyingFilterIndex,
						currentIndex == filterIndex,
						let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
						let image = UIImage(cgImage: cgImageOutput)
						DispatchQueue.main.async {
							self?.filterApplyingFinish(image: image, isFilter: isFilter, index: filterIndex)
							self?.lastApplyingFilter = filter
						}
					}
					else {
						DispatchQueue.main.async {
							self?.view?.stopSpinner()
						}
					}
				}
			}
		}
	}
// MARK: - Инструмент
	func applyInstrument(instrument: Filter, instrumentIndex: Int, parameter: FilterParameter, newValue: Float) {
		let isFilter = false
		filterApplyingPreparing(isFilter: isFilter)
//Запомним текущее значение параметра и сложим в стэк
		for param in instrumentsList[instrumentIndex].parameters where param.code == parameter.code {
			filtersStack.push((instrumentsList[instrumentIndex].code, param.code, param.currentValue))
		}
		instrumentsList[instrumentIndex].setValueForParameter(parameterCode: parameter.code,
															  newValue: parameter.currentValue)

		let instrumentQueue = DispatchQueue(label: "InstrumentQueue", qos: .userInteractive, attributes: .concurrent)
		instrumentQueue.async { [weak self] in
			self?.imagesState.instrumentSourceImage.setFiltersList(filtersList: self?.instrumentsList,
																   isFilter: isFilter) { ciImage, rect in
				if let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
					let image = UIImage(cgImage: cgImageOutput)
					DispatchQueue.main.async {
						self?.filterApplyingFinish(image: image, isFilter: isFilter, index: instrumentIndex)
					}
				}
				else {
					DispatchQueue.main.async {
						self?.view?.stopSpinner()
					}
				}
			}
		}
	}

	var currentId: String {
		return id
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
		return imageStack.isEmpty == false
	}

	func triggerViewReadyEvent() {
		view?.setImage(image: imagesState.editingImage)
		createFilteredImageCollection()
	}

	func inject(view: IImageEditorViewController) {
		self.view = view
	}

	func getCurrentInstrumentParameters(instrumentIndex: Int) -> [FilterParameter] {
		return instrumentsList[instrumentIndex].parameters
	}

	func saveImage() {
		applyFiltersToOriginalImage { [weak self] image in
			guard let imageData = image.pngData(), let self = self else { return }
			let savingImageQueue = DispatchQueue(label: "saveImage", qos: .userInteractive, attributes: .concurrent)
			if self.isNewImage {
				savingImageQueue.async {
					self.repository.saveImage(id: self.id, data: imageData as NSData) { object in
						guard let imageModel = object as? ImageModel else { return }
						DispatchQueue.main.async {
							guard let mainVC = (UIApplication.shared.windows.first?.rootViewController as?
								UINavigationController)?.viewControllers.first as? IImagesCollectionViewController else { return }
							mainVC.saveNewImage(newImageModel: imageModel)
						}
					}
				}
			}
			else {
				savingImageQueue.async {
					self.repository.updateImage(id: self.id, data: imageData as NSData) { imageModel in
						DispatchQueue.main.async {
							guard let mainVC = (UIApplication.shared.windows.first?.rootViewController as?
								UINavigationController)?.viewControllers.first as? IImagesCollectionViewController else { return }
							mainVC.updateImage(imageModel: imageModel)
						}
					}
				}
			}
			self.moveToMain()
		}
	}

	func moveBack() {
		self.router.moveBack()
	}

	func moveToMain() {
		self.router.moveToMain()
	}
// MARK: - Кроп
	func cropImage(cropRect: CGRect) {
		guard let croppedImage = imagesState.editingImage.cropImage(to: cropRect) else { return }
		imageStack.push(self.imagesState.editingImage)
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
		imagesState.editingImage = croppedImage
		imagesState.filterSourceImage = croppedImage
		imagesState.instrumentSourceImage = croppedImage
		view?.setImage(image: imagesState.editingImage)
	}
}
// MARK: - private extension
private extension ImageEditorPresenter
{
	func createFilteredImageCollection() {
		guard let preview = imagesState.sourceImage.resizeImage(to: UIConstants.collectionViewCellWidth) else { return }
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
		filterQueue.async { [weak self] in
			self?.filtersList.forEach{
				preview.setFiltersList(filtersList: [$0], isFilter: true) { ciImage, rect in
					if let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
						let image = UIImage(cgImage: cgImageOutput)
						self?.filteredPreviews.append(image)
					}
				}
			}
			DispatchQueue.main.async {
				self?.view?.refreshButtonsState(imagesStackIsEmpty: self?.imageStack.isEmpty ?? true)
				self?.view?.reloadFilterPreviews()
			}
		}
	}

	func filterApplyingPreparing(isFilter: Bool) {
		view?.startSpinner()
		imageStack.push(imagesState.editingImage)
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
	}

	func filterApplyingFinish(image: UIImage, isFilter: Bool, index: Int) {
		self.view?.setImage(image: image)
		self.imagesState.editingImage = image
		self.view?.stopSpinner()
		if isFilter {
			self.previousAppliedFilterIndex = index
			self.imagesState.instrumentSourceImage = image
		}
		else {
			self.previousAppliedInstrumentIndex = index
			self.imagesState.filterSourceImage = image
		}
	}

	func applyFiltersToOriginalImage(completion: @escaping (UIImage) -> Void) {
		self.view?.userInteractionEnabled = false
		view?.startSpinner()
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
		filterQueue.async {[weak self] in
			if let filter = self?.lastApplyingFilter {
				self?.imagesState.sourceImage.setFiltersList(filtersList: [filter], isFilter: true) { ciImage, rect in
					if let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
						self?.imagesState.sourceImage = UIImage(cgImage: cgImageOutput)
					}
				}
			}
			self?.imagesState.sourceImage.setFiltersList(filtersList: self?.instrumentsList, isFilter: false) { ciImage, rect in
				if let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
					self?.imagesState.sourceImage = UIImage(cgImage: cgImageOutput)
				}
			}
			DispatchQueue.main.async {
				self?.view?.stopSpinner()
				self?.view?.userInteractionEnabled = true
				if let image = self?.imagesState.sourceImage {
					completion(image)
				}
			}
		}
	}
}
