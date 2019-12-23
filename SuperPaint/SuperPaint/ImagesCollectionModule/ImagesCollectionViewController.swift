//
//  ImagesCollectionViewController.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImagesCollectionViewController: UIViewController
{
	private let imagesCollectionPresenter: IImagesCollectionPresenter
	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = ViewConstants.spacingBetweenCells
		layout.minimumInteritemSpacing = ViewConstants.spacingBetweenCells
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		return collectionView
	}()
	private var safeArea = UILayoutGuide()

	init(presenter: IImagesCollectionPresenter) {
		self.imagesCollectionPresenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		self.safeArea = self.view.layoutMarginsGuide
		self.setupSettingsForNavigationBar()
		self.setupCollectionView()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		let selectedCells = self.collectionView.indexPathsForSelectedItems
		selectedCells?.forEach { indexPath in
			self.collectionView.deselectItem(at: indexPath, animated: false)
		}
		if self.isEditing {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
																	 target: self,
																	 action: #selector(removeImages))
			self.navigationItem.rightBarButtonItem?.isEnabled = false
		}
		else {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
																	 target: self,
																	 action: #selector(addNewImage))
			self.navigationItem.rightBarButtonItem?.isEnabled = true
		}
		self.collectionView.allowsMultipleSelection = true
		let indexPaths = self.collectionView.indexPathsForVisibleItems
		for indexPath in indexPaths {
			if indexPath.row == 0 {
				let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell
				cell?.imageView.image = Images.newImageDisabled
				cell?.isUserInteractionEnabled = false
				self.collectionView.reloadItems(at: [indexPath])
				continue
			}
			let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell
			cell?.isInEditingMode = editing
		}
		self.collectionView.collectionViewLayout.invalidateLayout()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.collectionView.collectionViewLayout.invalidateLayout()
	}
}

private extension ImagesCollectionViewController
{
	// MARK: - Настройка collection view
	func setupCollectionView() {
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.register(ImageCell.self,
									 forCellWithReuseIdentifier: ImageCell.cellReuseIdentifier)
		self.view.addSubview(self.collectionView)
		self.collectionView.translatesAutoresizingMaskIntoConstraints = false
		self.collectionView.backgroundColor = .white
		NSLayoutConstraint.activate([
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.topAnchor.constraint(equalTo: self.safeArea.topAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.safeArea.bottomAnchor),
		])
	}

	// MARK: - Настройки navigation bar
	func setupSettingsForNavigationBar() {
		self.title = "Gallery"
		self.navigationItem.leftBarButtonItem = editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
																 target: self,
																 action: #selector(addNewImage))
		guard let font = Fonts.verdanaBold20 else { return }
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
	}

	// MARK: - Создаем и показываем Alert Controller на экране
	func openActionSheet() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
			self.chooseImagePicker(source: .camera)
		}
		cameraAction.setValue(Images.cameraIcon, forKey: "image")
		cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		let libraryAction = UIAlertAction(title: "Library", style: .default) { _ in

			self.chooseImagePicker(source: .photoLibrary)
		}
		libraryAction.setValue(Images.libraryIcon, forKey: "image")
		libraryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		let webAction = UIAlertAction(title: "Web search", style: .default) { _ in
			// TODO: - move to web search QIS-27
		}
		webAction.setValue(Images.webIcon, forKey: "image")
		webAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		actionSheet.addAction(cameraAction)
		actionSheet.addAction(libraryAction)
		actionSheet.addAction(webAction)
		actionSheet.addAction(cancelAction)
		present(actionSheet, animated: true)
	}

	// MARK: - Действие добавления новой картинки
	@objc func addNewImage() {
		self.openActionSheet()
	}

	// MARK: - Действие удаления выбранных картинок
	@objc func removeImages() {
		// TODO: - remove images QIS-25
	}
}

// MARK: - UICollectionViewDelegate
extension ImagesCollectionViewController: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.row == 0 && self.isEditing == false {
			self.collectionView.deselectItem(at: indexPath, animated: false)
			self.openActionSheet()
		}
		else if indexPath.row != 0 && self.isEditing == false {
			self.collectionView.deselectItem(at: indexPath, animated: false)
			guard let image = (self.collectionView.cellForItem(at: indexPath) as? ImageCell)?.imageView.image else { return }
			self.imagesCollectionPresenter.onCellPressed(with: image)
		}
		else if indexPath.row != 0 && self.isEditing {
			self.navigationItem.rightBarButtonItem?.isEnabled = true
		}
	}

	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if let selectedItems = self.collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
			self.navigationItem.rightBarButtonItem?.isEnabled = false
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ImagesCollectionViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return 35
	}

	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = self.collectionView.dequeueReusableCell(
			withReuseIdentifier: ImageCell.cellReuseIdentifier,
			for: indexPath) as? ImageCell ?? ImageCell(frame: .zero)
		if indexPath.row == 0 {
			if self.isEditing {
				cell.imageView.image = Images.newImageDisabled
				cell.isUserInteractionEnabled = false
			}
			else {
				cell.imageView.image = Images.newImageEnabled
				cell.isUserInteractionEnabled = true
			}
			cell.isInEditingMode = false
			cell.selectionImageView.image = nil
		}
		else {
			cell.isUserInteractionEnabled = true
			if self.isEditing {
				cell.isInEditingMode = true
			}
			else {
				cell.isInEditingMode = false
			}
			cell.selectionImageView.image = cell.isSelected ? Images.selected : Images.notSelected
			cell.imageView.image = Images.newImageDisabled
		}
		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let totalSpacing = (2 * ViewConstants.spacing) + ((ViewConstants.numberOfItemsPerRow - 1) *
			ViewConstants.spacingBetweenCells)
		let width = (self.collectionView.bounds.width - totalSpacing) / ViewConstants.numberOfItemsPerRow
		return CGSize(width: width, height: width)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		let spacing = ViewConstants.spacing
			return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
	}
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImagesCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func chooseImagePicker(source: UIImagePickerController.SourceType) {
		if UIImagePickerController.isSourceTypeAvailable(source) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.allowsEditing = true
			imagePicker.sourceType = source
			present(imagePicker, animated: true)
		}
	}

	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let image = info[.editedImage] as? UIImage else {
			dismiss(animated: true, completion: nil)
			return
		}
		self.imagesCollectionPresenter.onCellPressed(with: image)
		dismiss(animated: true, completion: nil)
	}
}

extension ImagesCollectionViewController: IImagesCollectionViewController
{
}
