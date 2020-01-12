//
//  CollectionViewActivityIndicator.swift
//  SuperPaint
//
//  Created by Иван Медведев on 12/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

final class CollectionViewActivityIndicator: UICollectionReusableView
{
	static let cellReuseIdentifier = "activityIndicator"
	let activityIndicator = UIActivityIndicatorView(style: .gray)

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupActivityIndicator()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

private extension CollectionViewActivityIndicator
{
	func setupActivityIndicator() {
		self.addSubview(self.activityIndicator)
		self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false

		self.activityIndicator.stopAnimating()
		self.activityIndicator.isHidden = true

		NSLayoutConstraint.activate([
			self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
		])
	}
}
