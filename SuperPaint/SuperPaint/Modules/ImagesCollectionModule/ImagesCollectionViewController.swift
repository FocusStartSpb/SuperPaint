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
		layout.minimumLineSpacing = UIConstants.spacingBetweenCells
		layout.minimumInteritemSpacing = UIConstants.spacingBetweenCells
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
		self.view.backgroundColor = UIConstants.backgroundColor
		self.safeArea = self.view.layoutMarginsGuide
		self.setupSettingsForNavigationBar()
		self.setupCollectionView()
		self.loadImages()
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
		self.collectionView.alwaysBounceVertical = true
		self.collectionView.backgroundColor = UIConstants.backgroundColor
		NSLayoutConstraint.activate([
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.topAnchor.constraint(equalTo: self.safeArea.topAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.safeArea.bottomAnchor),
		])
	}

	// MARK: - Настройки navigation bar
	func setupSettingsForNavigationBar() {
		self.title = "Super Paint"
		self.navigationItem.leftBarButtonItem = editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
																 target: self,
																 action: #selector(addNewImage))
		guard let font = Fonts.chalkduster20 else { return }
		self.navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.font: font,
			NSAttributedString.Key.foregroundColor: UIConstants.textColor,
		]
		self.navigationController?.navigationBar.barTintColor = UIConstants.backgroundColor
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
			self.imagesCollectionPresenter.pushWebSearchModule()
			actionSheet.dismiss(animated: true)
		}
		webAction.setValue(Images.webIcon, forKey: "image")
		webAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		actionSheet.addAction(cameraAction)
		actionSheet.addAction(libraryAction)
		actionSheet.addAction(webAction)
		actionSheet.addAction(cancelAction)
		actionSheet.removeBrokenConstraint()
		present(actionSheet, animated: true)
	}

	// MARK: - Загружаем картинки из базы данных
	func loadImages() {
		self.imagesCollectionPresenter.loadImages()
	}
	// MARK: - Действие добавления новой картинки
	@objc func addNewImage() {
		self.openActionSheet()
	}

	// MARK: - Действие удаления выбранных картинок
	@objc func removeImages() {
		let alertController = UIAlertController(title: "Delete images",
												message: "Are you sure you want to delete these images?",
												preferredStyle: .alert)
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
			guard let selectedIndexes = self.collectionView.indexPathsForSelectedItems else { return }
			self.imagesCollectionPresenter.deleteImages(selectedIndexes)
			self.collectionView.deleteItems(at: selectedIndexes)
			self.navigationItem.rightBarButtonItem?.isEnabled = false
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alertController.addAction(deleteAction)
		alertController.addAction(cancelAction)
		present(alertController, animated: true)
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
			self.imagesCollectionPresenter.getImageModelAt(index: indexPath.row - 1, completion: { imageModel in
				guard let id = imageModel.id, let imageData = imageModel.imageData,
					let image = UIImage(data: imageData as Data) else { return }
				self.imagesCollectionPresenter.onCellPressed(id: id, image: image, isNewImage: false)
			})
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
		return self.imagesCollectionPresenter.getNumberOfImages()
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

			self.imagesCollectionPresenter.getImage(index: indexPath.row - 1, completion: { image in
				cell.imageView.image = image
			})
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
		let totalSpacing = (2 * UIConstants.spacing) + ((UIConstants.numberOfItemsPerRow - 1) *
			UIConstants.spacingBetweenCells)
		let width = (self.collectionView.bounds.width - totalSpacing) / UIConstants.numberOfItemsPerRow
		return CGSize(width: width, height: width)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		let spacing = UIConstants.spacing
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
			imagePicker.sourceType = source
			present(imagePicker, animated: true)
		}
	}

	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		picker.delegate = nil
		picker.dismiss(animated: true) { [weak self] in
			guard let image = (info[.originalImage] as? UIImage)?.verticalOrientationImage() else { return }

			let id = UUID().uuidString
			self?.imagesCollectionPresenter.onCellPressed(id: id, image: image, isNewImage: true)
		}
	}
}

// MARK: - IImagesCollectionViewController
extension ImagesCollectionViewController: IImagesCollectionViewController
{
	var navController: UINavigationController? {
		return self.navigationController
	}

	func reloadView() {
		self.collectionView.reloadData()
	}

	func saveNewImage(newImageModel: ImageModel) {
		self.imagesCollectionPresenter.saveNewImage(newImageModel: newImageModel)
	}

	func updateImage(imageModel: ImageModel) {
		self.imagesCollectionPresenter.updateImage(imageModel: imageModel)
	}
}
