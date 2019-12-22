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
		layout.minimumLineSpacing = Constants.spacingBetweenCells
		layout.minimumInteritemSpacing = Constants.spacingBetweenCells
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		return collectionView
	}()

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
		self.settingsForNavigationBar()
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
		}
		self.collectionView.allowsMultipleSelection = true
		let indexPaths = self.collectionView.indexPathsForVisibleItems
		for indexPath in indexPaths {
			if indexPath.row == 0 {
				let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell
				cell?.imageView.image = UIImage(named: "new_image_disabled")
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
			self.collectionView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
		])
	}

	func settingsForNavigationBar() {
		self.title = "Gallery"
		self.navigationItem.leftBarButtonItem = editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
																 target: self,
																 action: #selector(addNewImage))
		guard let font = Fonts.verdanaBold20 else { return }
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
	}

	@objc func addNewImage() {
		// (ED-XX) Add new image
	}

	@objc func removeImages() {
		// (ED-YY) Remove images
	}
}

extension ImagesCollectionViewController: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.row == 0 && self.isEditing == false {
			// (ED-XX) Add new image
		}
		else if indexPath.row != 0 && self.isEditing == false {
			// (ED-ZZ) Edit image
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
				cell.imageView.image = UIImage(named: "new_image_disabled")
				cell.isUserInteractionEnabled = false
			}
			else {
				cell.imageView.image = UIImage(named: "new_image_enabled")
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
			cell.selectionImageView.image = cell.isSelected ? UIImage(named: "selected") : UIImage(named: "not_selected")
			cell.imageView.image = nil
		}
		return cell
	}
}

extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let totalSpacing = (2 * Constants.spacing) + ((Constants.numberOfItemsPerRow - 1) * Constants.spacingBetweenCells)
		let width = (self.collectionView.bounds.width - totalSpacing) / Constants.numberOfItemsPerRow
		return CGSize(width: width, height: width)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		let spacing = Constants.spacing
			return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
	}
}

extension ImagesCollectionViewController: IImagesCollectionViewController
{
}
