//
//  EditorControlsCreator.swift
//  SuperPaint
//
//  Created by Stanislav on 21/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

enum EditorControlsCreator
{
	static func setupActionsView(actionsView: UIView, parentView: UIView) {
		actionsView.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(actionsView)
	}

	static func setButtonProperties(_ button: UIButton, parentView: UIView) {
		button.setTitleColor(.black, for: .normal)
		button.setTitleColor(.lightGray, for: .highlighted)
		button.setTitleColor(ViewConstants.systemButtonColor, for: .selected)
		button.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(button)
	}
// MARK: - Настройка кнопок
	static func setupButtons(filtersButton: UIButton, instrumentsButton: UIButton, parentView: UIView) {
		filtersButton.setTitle("Filters", for: .normal)
		instrumentsButton.setTitle("Instruments", for: .normal)
		setButtonProperties(filtersButton, parentView: parentView)
		setButtonProperties(instrumentsButton, parentView: parentView)
		NSLayoutConstraint.activate([
			filtersButton.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
			filtersButton.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
			filtersButton.topAnchor.constraint(equalTo: parentView.topAnchor),
			instrumentsButton.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
			instrumentsButton.topAnchor.constraint(equalTo: parentView.topAnchor),
			instrumentsButton.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
			filtersButton.widthAnchor.constraint(equalTo: instrumentsButton.widthAnchor),
			filtersButton.trailingAnchor.constraint(equalTo: instrumentsButton.leadingAnchor),
		])
	}
// MARK: - Настройка imageView
	static func setupImageView(imageView: UIImageView,
							   image: UIImage,
							   parentView: UIView) {
		imageView.image = image
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(imageView)
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: parentView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
			imageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
		])
	}
// MARK: - Настройка stackView
	static func setupStackView(verticalStack: UIStackView,
							   topActionsView: UIView,
							   bottomActionsView: UIView,
							   parentView: UIView,
							   safeArea: UILayoutGuide) {
		verticalStack.addArrangedSubview(topActionsView)
		verticalStack.addArrangedSubview(bottomActionsView)
		verticalStack.axis = .vertical
		verticalStack.distribution = .fill
		verticalStack.alignment = .fill
		verticalStack.spacing = 0.0
		verticalStack.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(verticalStack)
		NSLayoutConstraint.activate([
			verticalStack.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
			verticalStack.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
			verticalStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
			bottomActionsView.heightAnchor.constraint(equalToConstant: 35),
			topActionsView.heightAnchor.constraint(equalTo: bottomActionsView.heightAnchor, multiplier: 3),
		])
	}

// MARK: - Настройка collectionView
	static func setupCollectionViews(parentView: UIView,
									 filtersCollection: UICollectionView,
									 instrumentsCollection: UICollectionView) {

		parentView.isHidden = true
		setCollectionViewProperties(filtersCollection, parentView: parentView)
		setCollectionViewProperties(instrumentsCollection, parentView: parentView)
	}

	static func setCollectionViewProperties(_ collectionView: UICollectionView, parentView: UIView) {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		collectionView.setCollectionViewLayout(layout, animated: true)
		collectionView.backgroundColor = .clear
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isHidden = true
		parentView.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: parentView.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
		])
	}
// MARK: - Настройка activityIndicator
	static func setupSpinner(spinner: UIActivityIndicatorView, parentView: UIView) {
		spinner.style = .whiteLarge
		spinner.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(spinner)
		NSLayoutConstraint.activate([
			spinner.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
		])
	}
// MARK: - Настройка scrollView для зума картинки
	static func setupScrollView(scrollView: UIScrollView, parentView: UIView, verticalStack: UIStackView) {
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 4.0
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(scrollView)
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: parentView.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: verticalStack.topAnchor, constant: -10),
		])
	}
}
