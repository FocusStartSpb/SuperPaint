//
//  ImageEditorViewController.swift
//  SuperPaint
//
//  Created by Stanislav on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImageEditorViewController: UIViewController
{
// MARK: - Variables
	let presenter: IImageEditorPresenter
	let filtersCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	let instrumentsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	let imageView = UIImageView()
	let spinner = UIActivityIndicatorView()
	private let filtersButton = UIButton()
	private let instrumentsButton = UIButton()
	private let bottomButtonsView = UIView()
	private let verticalStack = UIStackView()
	private let scrollView = UIScrollView()

	var undoButton: UIBarButtonItem?
	var saveButton: UIBarButtonItem?
	var exportButton: UIBarButtonItem?
	private var cropButton: UIBarButtonItem?
	private var backButton: UIBarButtonItem?
	private var croppingView: CropView?

	var sliders: [String: [UIView]] = [:]
	private var safeArea = UILayoutGuide()
	private var scrollViewDefaultBounds: CGRect = .zero
	var selectedInstrumentIndex: Int = UIConstants.defaultInstrumentIndex
// MARK: - toggling panels
	private var showFilters: Bool {
		get {
			return filtersCollection.isHidden == false
		}
		set {
			instrumentsCollection.isHidden = true
			filtersCollection.isHidden = (newValue == false)
			filtersButton.isSelected = newValue
			instrumentsButton.isSelected = filtersButton.isSelected ? false : instrumentsButton.isSelected
		}
	}
	private var showInstruments: Bool {
		get {
			return instrumentsCollection.isHidden == false
		}
		set {
			filtersCollection.isHidden = true
			instrumentsCollection.isHidden = (newValue == false)
			if newValue == false {
				showSliders()
			}
			else {
				showSliders(instrumentIndex: selectedInstrumentIndex)
			}
			instrumentsButton.isSelected = newValue
			filtersButton.isSelected = instrumentsButton.isSelected ? false : filtersButton.isSelected
		}
	}
// MARK: - cropMode
	var cropMode: Bool {
		didSet {
			let imageRect = imageView.getImageRect(insideRect: scrollViewDefaultBounds)
			let normalMode = (cropMode == false)
			filtersButton.isEnabled = normalMode
			instrumentsButton.isEnabled = normalMode
			filtersButton.isSelected = filtersButton.isSelected && normalMode
			instrumentsButton.isSelected = instrumentsButton.isSelected && normalMode
			saveButton?.isEnabled = normalMode
			exportButton?.isEnabled = normalMode
			undoButton?.isEnabled = normalMode
			backButton?.isEnabled = normalMode
			instrumentsCollection.isHidden = true
			filtersCollection.isHidden = true
			//Переходим в режим кропа
			if cropMode {
				instrumentsCollection.isHidden = true
				filtersCollection.isHidden = true
				showSliders()
				croppingView = CropView(frame: imageRect)
				if let cropView = croppingView {
					scrollView.addSubview(cropView)
				}
			}
			// при возврате из кроп мода кропаем картинку
			else {
				if let cropView = croppingView {
					guard let image = imageView.image else { return }
					var cropRect = cropView.frame
					let imageWidth = image.size.width
					let imageHeight = image.size.height
					let widthScale = imageWidth / imageRect.width
					let heightScale = imageHeight / imageRect.height
					cropRect.origin.x = (cropRect.origin.x - imageRect.origin.x) * widthScale
					cropRect.origin.y = (cropRect.origin.y - imageRect.origin.y) * heightScale
					cropRect.size.width *= widthScale
					cropRect.size.height *= heightScale
					presenter.cropImage(cropRect: cropRect)
					cropView.removeFromSuperview()
				}
			}
		}
	}
// MARK: - init
	init(presenter: IImageEditorPresenter) {
		self.presenter = presenter
		self.cropMode = false
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupInitialState()
		presenter.triggerViewReadyEvent()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		scrollViewDefaultBounds = scrollView.bounds
	}
// MARK: - showSliders
	//Отображаем вью с параметрами для текущего инструмента
	//Если на вход ничего не пришло скрываем все
	func showSliders(instrumentIndex: Int? = nil) {
		if let index = instrumentIndex {
			for (key, _) in sliders {
				sliders[key]?.forEach{ slider in slider.isHidden = (key != presenter.instrumentsList[index].name) }
			}
		}
		else {
			for (key, _) in sliders {
				sliders[key]?.forEach{ slider in slider.isHidden = true }
			}
		}
	}
}

private extension ImageEditorViewController
{
// MARK: - Initial state
	func setupInitialState() {
		safeArea = self.view.layoutMarginsGuide
		self.view.backgroundColor = UIConstants.backgroundColor
		setupNavigationBarItems()

		EditorControlsCreator.setupButtonsView(actionsView: bottomButtonsView, parentView: self.view)
		EditorControlsCreator.setupButtons(filtersButton: filtersButton,
									 instrumentsButton: instrumentsButton,
									 parentView: bottomButtonsView)
		filtersButton.addTarget(self, action: #selector(toggleFiltersCollection), for: .touchUpInside)
		instrumentsButton.addTarget(self, action: #selector(toggleInstrumentsCollection), for: .touchUpInside)

		EditorControlsCreator.setupStackView(verticalStack: verticalStack,
									   bottomActionsView: bottomButtonsView,
									   parentView: self.view,
									   safeArea: safeArea)

		EditorControlsCreator.setupScrollView(scrollView: scrollView,
											  parentView: self.view,
											  verticalStack: verticalStack,
											  safeArea: safeArea)

		EditorControlsCreator.setupImageView(imageView: imageView,
											 parentView: scrollView)

		EditorControlsCreator.setupCollectionViews(verticalStack: verticalStack,
											 filtersCollection: filtersCollection,
											 instrumentsCollection: instrumentsCollection)

		EditorControlsCreator.setupSpinner(spinner: spinner, parentView: imageView)

		filtersCollection.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.cellReuseIdentifier)
		instrumentsCollection.register(InstrumentCell.self, forCellWithReuseIdentifier: InstrumentCell.cellReuseIdentifier)

		createSliders()

		setDelegates()
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(defaultZoom))
		doubleTap.numberOfTapsRequired = 2
		scrollView.addGestureRecognizer(doubleTap)

		instrumentsCollection.selectItem(at: IndexPath(row: UIConstants.defaultInstrumentIndex, section: 0),
										 animated: true,
										 scrollPosition: .centeredHorizontally)
	}

	func setDelegates() {
		scrollView.delegate = self
		filtersCollection.dataSource = self
		filtersCollection.delegate = self
		instrumentsCollection.dataSource = self
		instrumentsCollection.delegate = self
	}
// MARK: - setupNavigationBarItems
	func setupNavigationBarItems() {
		self.navigationItem.hidesBackButton = true
		backButton = UIBarButtonItem(title: "❮ Back",
											style: .plain,
											target: self,
											action: #selector(back))
		self.navigationItem.leftBarButtonItem = backButton
		saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
		exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportPressed))
		undoButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(undoPressed))
		cropButton = UIBarButtonItem(image: Images.cropIcon,
									 landscapeImagePhone: Images.cropIcon,
									 style: .plain,
									 target: self,
									 action: #selector(toggleCropMode))
		undoButton?.isEnabled = false
		cropButton?.tintColor = UIConstants.systemButtonColor
		let barButtonItems = [saveButton, exportButton, undoButton, cropButton].compactMap{ $0 }
		self.navigationItem.setRightBarButtonItems(barButtonItems, animated: true)
	}
// MARK: - createSliders
//генерим вью со слайдерами для всех возможных инструметов
//в итоге скрываем их
	func createSliders() {
		for (index, instrument) in presenter.instrumentsList.enumerated() {
			instrument.parameters.forEach { parameter in
				if sliders[instrument.name] == nil {
					sliders[instrument.name] = []
				}
				sliders[instrument.name]?.append(EditorControlsCreator.createSlider(verticalStack: verticalStack,
																					presenter: presenter,
																					instrument: instrument,
																					parameter: parameter,
																					instrumentIndex: index))
			}
		}
		refreshSlidersValues()
		showSliders()
	}

// MARK: - defaultZoom
//По двойному тапу на картинке увеличиваем ее в 2 раза
//По следующему двойному тапу возвращаем исходный масштаб
	@objc func defaultZoom() {
		guard cropMode == false else { return }
		if scrollView.zoomScale == UIConstants.defaultZoomScale {
			scrollView.setZoomScale(UIConstants.doubleTapZoomScale, animated: true)
		}
		else {
			scrollView.setZoomScale(UIConstants.defaultZoomScale, animated: true)
		}
	}
// MARK: - back
//По кнопке назад спрашиваем сохранить или нет
	@objc func back() {
		if presenter.imageEdited {
			let backQuestionAlert = UIAlertController(title: "Image changed",
			message: "Changes not saved. Are you sure want to quit?",
			preferredStyle: .alert)

			let quitAction = UIAlertAction(title: "Quit", style: .destructive) { _ in
				self.presenter.moveBack()
			}
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
			backQuestionAlert.addAction(quitAction)
			backQuestionAlert.addAction(cancelAction)
			present(backQuestionAlert, animated: true)
		}
		else {
			presenter.moveBack()
		}
	}
// MARK: - bar button actions
	@objc func toggleFiltersCollection(_ sender: UIButton) {
		showFilters = (showFilters == false)
	}

	@objc func toggleInstrumentsCollection(_ sender: UIButton) {
		showInstruments = (showInstruments == false)
	}

	@objc func savePressed(_ sender: UIBarButtonItem) {
		self.presenter.saveImage()
	}

	@objc func exportPressed(_ sender: UIBarButtonItem) {
		guard let image = self.imageView.image?.pngData() else {
			return
		}

		let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		present(activityVC, animated: true)
	}

	@objc func undoPressed(_ sender: UIBarButtonItem) {
		presenter.undoAction()
	}
// MARK: - Crop mode
	@objc func toggleCropMode(_ sender: UIBarButtonItem) {
		scrollView.setZoomScale(UIConstants.defaultZoomScale, animated: true)
		cropMode = (cropMode == false)
	}
}
