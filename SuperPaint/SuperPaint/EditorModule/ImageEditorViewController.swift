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
	private let topActionsView = UIView()
	private let bottomActionsView = UIView()
	private let verticalStack = UIStackView()

	private var safeArea = UILayoutGuide()
	private var image = UIImage()

	private var showFilters: Bool {
		get {
			return filtersCollection.isHidden == false
		}
		set {
			instrumentsCollection.isHidden = true
			topActionsView.isHidden = (newValue == false)
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
			topActionsView.isHidden = (newValue == false)
			instrumentsCollection.isHidden = (newValue == false)
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
}
// MARK: - IImageEditorViewController
extension ImageEditorViewController: IImageEditorViewController
{
}
// MARK: - UICollectionViewDataSource
extension ImageEditorViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == filtersCollection {
			return presenter.numberOfFilters
		}
		else {
// TODO: - количество инструментов из презентера QIS-16
			return 8
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == filtersCollection {
//TODO: - добавить новый класс для кастомной ячейки для фильтров, и использовать его тут QIS-17
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.cellReuseIdentifier,
														  for: indexPath) as? FilterCell ?? FilterCell(frame: .zero)
			cell.imageView.image = presenter.currentImage
			cell.label.text = "filter"
			return cell
		}
		else {
//TODO: - добавить новый класс для кастомной ячейки для инструментов, и использовать его тут QIS-22
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "instrumentCell", for: indexPath)
			cell.backgroundColor = .orange
			return cell
		}
	}
}
// MARK: - UICollectionViewDelegate
extension ImageEditorViewController: UICollectionViewDelegate
{
// TODO: - обработка кликов по фильтрам и вызов применения фильтров из презентера QIS-21
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == filtersCollection {
			collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
		}
	}
// TODO: - обработка кликов по инструментам QIS-23
}
// MARK: - UICollectionViewDelegateFlowLayout
extension ImageEditorViewController: UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: topActionsView.bounds.height * 0.7, height: topActionsView.bounds.height * 0.7)
	}
}
// MARK: - private extension
private extension ImageEditorViewController
{
	func setupInitialState() {
		safeArea = self.view.layoutMarginsGuide
		self.view.backgroundColor = .white
		self.image = presenter.currentImage
		EditorControlsCreator.setupActionsView(actionsView: topActionsView, parentView: self.view)
		EditorControlsCreator.setupActionsView(actionsView: bottomActionsView, parentView: self.view)
		EditorControlsCreator.setupButtons(filtersButton: filtersButton,
									 instrumentsButton: instrumentsButton,
									 parentView: bottomActionsView)
		filtersButton.addTarget(self, action: #selector(toggleFiltersCollection), for: .touchUpInside)
		instrumentsButton.addTarget(self, action: #selector(toggleInstrumentsCollection), for: .touchUpInside)

		EditorControlsCreator.setupStackView(verticalStack: verticalStack,
									   topActionsView: topActionsView,
									   bottomActionsView: bottomActionsView,
									   parentView: self.view,
									   safeArea: safeArea)

		EditorControlsCreator.setupImageView(imageView: imageView,
									   image: image,
									   parentView: self.view,
									   safeArea: safeArea,
									   verticalStack: verticalStack)

		EditorControlsCreator.setupCollectionViews(parentView: topActionsView,
											 filtersCollection: filtersCollection,
											 instrumentsCollection: instrumentsCollection)
		filtersCollection.dataSource = self
		filtersCollection.delegate = self
		instrumentsCollection.dataSource = self
		instrumentsCollection.delegate = self
		filtersCollection.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.cellReuseIdentifier)
		instrumentsCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "instrumentCell")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
																 style: .plain,
																 target: self,
																 action: #selector(savePressed))
	}

	@objc func toggleFiltersCollection(_ sender: UIButton) {
		showFilters = (showFilters == false)
	}

	@objc func toggleInstrumentsCollection(_ sender: UIButton) {
		showInstruments = (showInstruments == false)
	}

	@objc func savePressed(_ sender: UIBarButtonItem) {
	}
}
