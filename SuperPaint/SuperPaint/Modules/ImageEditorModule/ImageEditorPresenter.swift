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
	var cropFilter: Filter
	var filteredPreviews: [UIImage] = []
	private var imageStack = ImagesStack()
	private var filtersStack = FiltersStack()
	private var cropRectStack = CropRectStack()
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
	private var currentCropRectForSourceImage: CGRect?

	init(router: IImageEditorRouter, repository: IDatabaseRepository, id: String, image: UIImage, isNewImage: Bool) {
		self.router = router
		self.repository = repository
		self.id = id
		self.imagesState.sourceImage = image
		filtersList = FiltersList.allCases.filter{ $0.getFilter().actionType == .filter }.map{ $0.getFilter() }
		instrumentsList = FiltersList.allCases.filter{ $0.getFilter().actionType == .instrument }.map{ $0.getFilter() }
		cropFilter = FiltersList.allCases.filter{ $0.getFilter().actionType == .crop }.map{ $0.getFilter() }[0]
		self.isNewImage = isNewImage
		guard let resizedImage = image.resizeImage(to: UIConstants.editorImageDimension) else { return }
		self.imagesState.editingImage = resizedImage
		self.imagesState.instrumentSourceImage = resizedImage
		self.imagesState.filterSourceImage = resizedImage
	}
}
extension ImageEditorPresenter: IImageEditorPresenter
{
	//MARK: - Undo
	func undoAction() {
		if let lastImage = imageStack.pop() {
			self.imagesState.editingImage = lastImage
			view?.setImage(image: lastImage)
		}
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
		previousAppliedFilterIndex = nil
		if let lastChangedInstrumentsList = filtersStack.pop(), lastChangedInstrumentsList.count > 0 {
			switch lastChangedInstrumentsList[0].actionType {
			case .instrument:
				instrumentsList = lastChangedInstrumentsList
				view?.refreshSlidersValues()
			case .crop:
				if let rect = cropRectStack.pop() {
					currentCropRectForSourceImage = rect
				}
			default:
				break
			}
		}
	}
// MARK: - Фильтр
	func applyFilter(filterIndex: Int) {
		let actionType: ActionType = .filter
		currentApplyingFilterIndex = filterIndex
		//Если фильтр уже применен не применяем снова
		var currentFilterAlreadyApplied = false
		if let previousIndex = previousAppliedFilterIndex, previousIndex == filterIndex {
			currentFilterAlreadyApplied = true
		}
		let filter = filtersList[filterIndex]
		if currentFilterAlreadyApplied == false {
			filterApplyingPreparing()
			let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
			filterQueue.async { [weak self] in
				self?.imagesState.filterSourceImage.setFiltersList(filtersList: [filter],
																   actionType: actionType) { ciImage, rect in
					//применять будем только последний нажатый фильтр
					if let currentIndex = self?.currentApplyingFilterIndex,
						currentIndex == filterIndex,
						let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
						let image = UIImage(cgImage: cgImageOutput)
						DispatchQueue.main.async {
							self?.filterApplyingFinish(image: image, actionType: actionType, index: filterIndex)
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
		let actionType: ActionType = .instrument

		filterApplyingPreparing()
//Запомним текущее значение параметра и сложим в стэк
		for param in instrumentsList[instrumentIndex].parameters where param.code == parameter.code {
			filtersStack.push(instrumentsList)
		}
		instrumentsList[instrumentIndex].setValueForParameter(parameterCode: parameter.code,
															  newValue: parameter.currentValue)

		let instrumentQueue = DispatchQueue(label: "InstrumentQueue", qos: .userInteractive, attributes: .concurrent)
		instrumentQueue.async { [weak self] in
			self?.imagesState.instrumentSourceImage.setFiltersList(filtersList: self?.instrumentsList,
																   actionType: actionType) { ciImage, rect in
				if let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
					let image = UIImage(cgImage: cgImageOutput)
					DispatchQueue.main.async {
						self?.filterApplyingFinish(image: image, actionType: actionType, index: instrumentIndex)
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
// MARK: - Save
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
	func cropImage(imageRect: CGRect, cropRect: CGRect) {
		let actionType: ActionType = .crop
		filtersStack.push([cropFilter])
		let croppingRect = imagesState.editingImage.getCroppingRect(from: imageRect, to: cropRect)
		currentCropRectForSourceImage = imagesState.sourceImage.getCroppingRect(from: imageRect,
																	  to: cropRect,
																	  sourceSize: currentCropRectForSourceImage?.size ?? imagesState.sourceImage.size)
		cropRectStack.push(currentCropRectForSourceImage)
		let cropVector = CIVector(cgRect: croppingRect)
		cropFilter.setValueForParameter(parameterCode: "inputRectangle", newValue: cropVector)
		let filter = cropFilter
		filterApplyingPreparing()
		let cropQueue = DispatchQueue(label: "CropQueue", qos: .userInteractive, attributes: .concurrent)
		cropQueue.async { [weak self] in
			self?.imagesState.editingImage.setFiltersList(filtersList: [filter],
														  actionType: actionType) { ciImage, _ in
				if let cgImageOutput = self?.context.createCGImage(ciImage, from: ciImage.extent) {
					let image = UIImage(cgImage: cgImageOutput)
					DispatchQueue.main.async {
						self?.filterApplyingFinish(image: image, actionType: actionType)
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
// MARK: - private extension
private extension ImageEditorPresenter
{
	func createFilteredImageCollection() {
		guard let preview = imagesState.sourceImage.resizeImage(to: UIConstants.collectionViewCellWidth) else { return }
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
		let actionType: ActionType = .filter
		filterQueue.async { [weak self] in
			self?.filtersList.forEach{
				preview.setFiltersList(filtersList: [$0], actionType: actionType) { ciImage, rect in
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

	func filterApplyingPreparing() {
		view?.startSpinner()
		imageStack.push(imagesState.editingImage)
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
	}

	func filterApplyingFinish(image: UIImage, actionType: ActionType, index: Int? = nil) {
		self.view?.setImage(image: image)
		self.imagesState.editingImage = image
		self.view?.stopSpinner()
		switch actionType {
		case .filter:
			if let index = index {
				self.previousAppliedFilterIndex = index
				self.imagesState.instrumentSourceImage = image
			}
		case .instrument:
			if let index = index {
				self.previousAppliedInstrumentIndex = index
				self.imagesState.filterSourceImage = image
			}
		case .crop:
			self.imagesState.editingImage = image
			self.imagesState.filterSourceImage = image
			self.imagesState.instrumentSourceImage = image
		}
	}
// MARK: - apply filter to original
	func applyFiltersToOriginalImage(completion: @escaping (UIImage) -> Void) {
		self.view?.userInteractionEnabled = false
		view?.startSpinner()
		var lastCropFilter = cropFilter
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
		filterQueue.async {[weak self] in
			var actionType: ActionType = .crop
			if let rect = self?.currentCropRectForSourceImage {
				let cropVector = CIVector(cgRect: rect)
				lastCropFilter.setValueForParameter(parameterCode: "inputRectangle", newValue: cropVector)
				self?.imagesState.sourceImage.setFiltersList(filtersList: [lastCropFilter],
															  actionType: actionType) { ciImage, _ in
					if let cgImageOutput = self?.context.createCGImage(ciImage, from: ciImage.extent) {
						self?.imagesState.sourceImage = UIImage(cgImage: cgImageOutput)
					}
				}
			}
			actionType = .filter
			if let filter = self?.lastApplyingFilter {
				self?.imagesState.sourceImage.setFiltersList(filtersList: [filter],
															 actionType: actionType) { ciImage, rect in
					if let cgImageOutput = self?.context.createCGImage(ciImage, from: rect) {
						self?.imagesState.sourceImage = UIImage(cgImage: cgImageOutput)
					}
				}
			}
			actionType = .instrument
			self?.imagesState.sourceImage.setFiltersList(filtersList: self?.instrumentsList,
														 actionType: actionType) { ciImage, rect in
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
