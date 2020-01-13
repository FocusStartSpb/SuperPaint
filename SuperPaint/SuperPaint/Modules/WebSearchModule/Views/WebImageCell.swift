//
//  WebImageCell.swift
//  SuperPaint
//
//  Created by Иван Медведев on 09/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

final class WebImageCell: UICollectionViewCell
{
	static let cellReuseIdentifier = "webImageCell"
	let imageView = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.clipsToBounds = true
		self.layer.borderWidth = 0.3
		self.layer.borderColor = UIColor.lightGray.cgColor
		self.setupImageView()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

private extension WebImageCell
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
		self.imageView.backgroundColor = .lightGray
	}
}
