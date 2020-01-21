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
	// MARK: - Undo
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
				self.imagesState.filterSourceImage = self.imagesState.editingImage
			case .crop:
				if let rect = cropRectStack.pop() {
					currentCropRectForSourceImage = rect
				}
			case .filter:
				self.imagesState.instrumentSourceImage = self.imagesState.editingImage
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
			applyCIFilter(to: imagesState.filterSourceImage,
						  actionType: actionType,
						  filtersToApply: [filter],
						  indexForSynchronize: filterIndex) {[weak self] filteredImage in
							self?.previousAppliedFilterIndex = filterIndex
							self?.imagesState.instrumentSourceImage = filteredImage
			}
		}
	}
// MARK: - Инструмент
	func applyInstrument(instrument: Filter, instrumentIndex: Int, parameter: FilterParameter, newValue: Float) {
		let actionType: ActionType = .instrument

		filtersStack.push(instrumentsList)
		instrumentsList[instrumentIndex].setValueForParameter(parameterCode: parameter.code,
															  newValue: parameter.currentValue)

		applyCIFilter(to: imagesState.instrumentSourceImage,
					  actionType: actionType,
					  filtersToApply: instrumentsList) {[weak self] filteredImage in
						self?.imagesState.filterSourceImage = filteredImage
		}
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
		applyCIFilter(to: imagesState.editingImage,
					  actionType: actionType,
					  filtersToApply: [filter]){[weak self] filteredImage in
						self?.imagesState.editingImage = filteredImage
						self?.imagesState.filterSourceImage = filteredImage
						self?.imagesState.instrumentSourceImage = filteredImage
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
			guard let rootViewController = (UIApplication.shared.windows.first?.rootViewController as?
			UINavigationController)?.viewControllers.first as? IImagesCollectionViewController else { return }
			let savingImageQueue = DispatchQueue(label: "saveImage", qos: .userInteractive, attributes: .concurrent)
			savingImageQueue.async { [weak self] in
				if let newImageFlag = self?.isNewImage, let imageID = self?.id {
					self?.repository.saveImage(id: imageID,
											  data: imageData as NSData,
											  isNewImage: newImageFlag) { imageModel in
												DispatchQueue.main.async {
													if newImageFlag {
														rootViewController.saveNewImage(newImageModel: imageModel)
													}
													else {
														rootViewController.updateImage(imageModel: imageModel)
													}
													self?.moveToMain()
												}
					}
				}
			}
		}
	}

	func moveBack() {
		self.router.moveBack()
	}

	func moveToMain() {
		self.router.moveToMain()
	}
}

private extension ImageEditorPresenter
{
// MARK: - apply CIFilter
	func applyCIFilter(to image: UIImage,
					   actionType: ActionType,
					   filtersToApply: [Filter],
					   indexForSynchronize: Int? = nil,
					   completion: ((UIImage) -> Void)? = nil) {
		view?.startSpinner()
		filtersStack.push(filtersToApply)
		imageStack.push(imagesState.editingImage)
		view?.refreshButtonsState(imagesStackIsEmpty: imageStack.isEmpty)
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
		filterQueue.async { [weak self] in
			image.setFiltersList(filtersList: filtersToApply, actionType: actionType) { ciImage, rect in
				if let cgImage = self?.context.createCGImage(ciImage, from: rect){
					let filteredImage = UIImage(cgImage: cgImage)
					DispatchQueue.main.async {
						if indexForSynchronize == nil || self?.currentApplyingFilterIndex == indexForSynchronize {
							self?.view?.setImage(image: filteredImage)
							self?.imagesState.editingImage = filteredImage
							self?.view?.stopSpinner()
							completion?(filteredImage)
						}
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
// MARK: - create previews
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
// MARK: - apply filter to original
	func applyFiltersToOriginalImage(completion: @escaping (UIImage) -> Void) {
		self.view?.userInteractionEnabled = false
		view?.startSpinner()
		var applyingFilters: [Filter] = []
		var lastCropFilter = cropFilter
		let filterQueue = DispatchQueue(label: "FilterQueue", qos: .userInteractive, attributes: .concurrent)
		filterQueue.async {[weak self] in
			var actionType: ActionType = .instrument
			if let rect = self?.currentCropRectForSourceImage {
				let cropVector = CIVector(cgRect: rect)
				lastCropFilter.setValueForParameter(parameterCode: "inputRectangle", newValue: cropVector)
				applyingFilters.append(lastCropFilter)
				actionType = .crop
			}
			if let filter = self?.filtersStack.getLastFilterByType(actionType: .filter) {
				applyingFilters.append(filter)
			}
			if let instruments = self?.instrumentsList {
				applyingFilters += instruments
			}

			self?.imagesState.sourceImage.setFiltersList(filtersList: applyingFilters,
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
