//
//  ImageCell.swift
//  SuperPaint
//
//  Created by Иван Медведев on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell
{
	static let cellReuseIdentifier = "imageCell"
	let imageView = UIImageView()
	let selectionImageView = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.clipsToBounds = true
		self.layer.borderWidth = 0.3
		self.layer.borderColor = UIConstants.borderColor.cgColor
		self.setupImageView()
		self.setupSelectionImageView()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = UIConstants.cellCornerRadius
	}

	var isInEditingMode: Bool = false {
		didSet {
			self.selectionImageView.isHidden = (isInEditingMode == false)
		}
	}

	override var isSelected: Bool {
		didSet {
			if isInEditingMode {
				self.selectionImageView.image = isSelected ? Images.selected : Images.notSelected
			}
		}
	}
}

private extension ImageCell
{
	func setupImageView() {
		self.contentView.addSubview(self.imageView)
		self.imageView.translatesAutoresizingMaskIntoConstraints = false
		self.imageView.clipsToBounds = true
		self.imageView.contentMode = .scaleAspectFill
		NSLayoutConstraint.activate([
			self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
		])
		self.imageView.backgroundColor = UIConstants.backgroundCellColor
	}

	func setupSelectionImageView() {
		self.contentView.addSubview(self.selectionImageView)
		self.selectionImageView.translatesAutoresizingMaskIntoConstraints = false
		self.selectionImageView.clipsToBounds = true
		self.selectionImageView.contentMode = .scaleAspectFit
		NSLayoutConstraint.activate([
			self.selectionImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
															  constant: -(self.contentView.frame.width / 8)),
			self.selectionImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
															constant: -(self.contentView.frame.height / 8)),
			self.selectionImageView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 1 / 6),
			self.selectionImageView.widthAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 1 / 6),
		])
		self.selectionImageView.image = Images.notSelected
	}
}
