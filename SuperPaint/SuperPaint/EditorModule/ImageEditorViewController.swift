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
	private let presenter: IImageEditorPresenter
	private let filtersCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	private let instrumentsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	private let imageView = UIImageView()
	private let filtersButton = UIButton()
	private let instrumentsButton = UIButton()
	private let topActionsStackView = UIStackView()
	private let parametersStackView = UIStackView()
	private let bottomActionsView = UIView()
	private let verticalStack = UIStackView()
	private let spinner = UIActivityIndicatorView()
	private let scrollView = UIScrollView()

	private var saveButton: UIBarButtonItem?
	private var undoButton: UIBarButtonItem?
	private var sliders: [String: [UIView]] = [:]
	private var safeArea = UILayoutGuide()

	private var showFilters: Bool {
		get {
			return filtersCollection.isHidden == false
		}
		set {
			instrumentsCollection.isHidden = true
			parametersStackView.isHidden = true
			topActionsStackView.isHidden = (newValue == false)
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
			topActionsStackView.isHidden = (newValue == false)
			instrumentsCollection.isHidden = (newValue == false)
			parametersStackView.isHidden = (newValue == false)
			instrumentsButton.isSelected = newValue
			filtersButton.isSelected = instrumentsButton.isSelected ? false : filtersButton.isSelected
		}
	}

	init(presenter: IImageEditorPresenter) {
		self.presenter = presenter
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

	override func didMove(toParent parent: UIViewController?) {
		if parent == nil {
			back()
		}
	}
}
// MARK: - IImageEditorViewController
extension ImageEditorViewController: IImageEditorViewController
{
	func stopSpinner() {
		spinner.stopAnimating()
	}

	func startSpinner() {
		spinner.startAnimating()
	}

	func refreshButtonsState(imagesStackIsEmpty: Bool) {
		undoButton?.isEnabled = imagesStackIsEmpty ? false : true
	}

	func setImage(image: UIImage) {
		imageView.image = image
	}

	var navController: UINavigationController? {
		return self.navigationController
	}
}
// MARK: - UIScrollViewDelegate
extension ImageEditorViewController: UIScrollViewDelegate
{
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
}

// MARK: - UICollectionViewDataSource
extension ImageEditorViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == filtersCollection {
			return presenter.numberOfPreviews
		}
		else {
// TODO: - количество инструментов из презентера QIS-16
			return presenter.numberOfInstruments
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == filtersCollection {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.cellReuseIdentifier,
														  for: indexPath) as? FilterCell ?? FilterCell(frame: .zero)
			cell.imageView.image = presenter.filteredPreviews[indexPath.row]
			cell.label.text = presenter.filtersList[indexPath.row].name
			return cell
		}
		else {
//TODO: - добавить новый класс для кастомной ячейки для инструментов, и использовать его тут QIS-22
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InstrumentCell.cellReuseIdentifier,
														  for: indexPath) as? InstrumentCell ?? InstrumentCell(frame: .zero)
			cell.label.text = presenter.instrumentsList[indexPath.row].name
			return cell
		}
	}
}
// MARK: - UICollectionViewDelegate
extension ImageEditorViewController: UICollectionViewDelegate
{
// TODO: - обработка кликов по фильтрам и вызов применения фильтров из презентера QIS-21
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
		if collectionView == filtersCollection {
			presenter.applyFilter(filterIndex: indexPath.row)
		}
		else {
			showSliders(instrumentIndex: indexPath.row)
		}
	}
}
// MARK: - UICollectionViewDelegateFlowLayout
extension ImageEditorViewController: UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == filtersCollection {
			return CGSize(width: UIConstants.collectionViewCellWidth * 0.7,
						  height: UIConstants.filterCollectionViewCellHeight * 0.7)
		}
		else {
			return CGSize(width: UIConstants.collectionViewCellWidth,
						  height: UIConstants.instrumentCollectionViewCellHeight * 0.9)
		}
	}
}
// MARK: - private extension
private extension ImageEditorViewController
{
	func setupInitialState() {
		safeArea = self.view.layoutMarginsGuide
		self.view.backgroundColor = UIConstants.backgroundColor
		setupNavigationBarItems()

		EditorControlsCreator.setupActionsView(actionsView: topActionsStackView, parentView: self.view)
		EditorControlsCreator.setupActionsView(actionsView: bottomActionsView, parentView: self.view)
		EditorControlsCreator.setupButtons(filtersButton: filtersButton,
									 instrumentsButton: instrumentsButton,
									 parentView: bottomActionsView)
		filtersButton.addTarget(self, action: #selector(toggleFiltersCollection), for: .touchUpInside)
		instrumentsButton.addTarget(self, action: #selector(toggleInstrumentsCollection), for: .touchUpInside)

		EditorControlsCreator.setupStackView(verticalStack: verticalStack,
									   topActionsView: topActionsStackView,
									   bottomActionsView: bottomActionsView,
									   parentView: self.view,
									   safeArea: safeArea)

		EditorControlsCreator.setupScrollView(scrollView: scrollView, parentView: self.view, verticalStack: verticalStack)
		EditorControlsCreator.setupImageView(imageView: imageView,
											 image: presenter.currentImage,
											 parentView: scrollView)

		EditorControlsCreator.setupCollectionViews(parentView: topActionsStackView,
											 filtersCollection: filtersCollection,
											 instrumentsCollection: instrumentsCollection,
											 parametersStackView: parametersStackView)

		EditorControlsCreator.setupSpinner(spinner: spinner, parentView: imageView)

		filtersCollection.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.cellReuseIdentifier)
		instrumentsCollection.register(InstrumentCell.self, forCellWithReuseIdentifier: InstrumentCell.cellReuseIdentifier)

		createSliders()

		setDelegates()
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(defaultZoom))
		doubleTap.numberOfTapsRequired = 2
		scrollView.addGestureRecognizer(doubleTap)
	}

	func setDelegates() {
		scrollView.delegate = self
		filtersCollection.dataSource = self
		filtersCollection.delegate = self
		instrumentsCollection.dataSource = self
		instrumentsCollection.delegate = self
	}

	func setupNavigationBarItems() {
		self.navigationItem.hidesBackButton = true
		let newBackButton = UIBarButtonItem(title: "❮ Back",
											style: .plain,
											target: self,
											action: #selector(back))
		self.navigationItem.leftBarButtonItem = newBackButton
		saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
		undoButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(undoPressed))
		undoButton?.isEnabled = false
		let barButtonItems = [saveButton, undoButton].compactMap{ $0 }
		self.navigationItem.setRightBarButtonItems(barButtonItems, animated: true)
	}
//генерим вью со слайдерами для всех возможных инструметов
//в итоге скрываем их
	func createSliders() {
		presenter.instrumentsList.forEach { instrument in
			instrument.parameters.forEach { parameter in
				if sliders[instrument.name] == nil {
					sliders[instrument.name] = []
				}
				sliders[instrument.name]?.append(EditorControlsCreator.createSlider(parentView: parametersStackView,
																					presenter: presenter,
																					instrument: instrument,
																					parameter: parameter))
			}
		}
		showSliders()
	}
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
//По двойному тапу на картинке увеличиваем ее в 2 раза
//По следующему двойному тапу возвращаем исходный масштаб
	@objc func defaultZoom() {
		if scrollView.zoomScale == 1.0 {
			scrollView.setZoomScale(2, animated: true)
		}
		else {
			scrollView.setZoomScale(1.0, animated: true)
		}
	}
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

	@objc func toggleFiltersCollection(_ sender: UIButton) {
		showFilters = (showFilters == false)
	}

	@objc func toggleInstrumentsCollection(_ sender: UIButton) {
		showInstruments = (showInstruments == false)
	}

	@objc func savePressed(_ sender: UIBarButtonItem) {
		self.presenter.saveImage()
	}

	@objc func undoPressed(_ sender: UIBarButtonItem) {
		presenter.undoAction()
	}
}
