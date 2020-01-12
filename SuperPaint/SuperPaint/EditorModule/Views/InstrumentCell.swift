//
//  InstrumentCell.swift
//  SuperPaint
//
//  Created by Stanislav on 05/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

final class InstrumentCell: UICollectionViewCell
{
	let label = UILabel()
	static let cellReuseIdentifier = "instrumentCell"

	override var isSelected: Bool {
		didSet {
			self.label.textColor = isSelected ? UIConstants.systemButtonColor : .black
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupInitialState()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension InstrumentCell
{
	func setupInitialState() {
		label.font = UIFont.systemFont(ofSize: 13)
		label.textColor = UIConstants.textColor
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(label)
		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: self.topAnchor),
			label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
		])
	}
}
