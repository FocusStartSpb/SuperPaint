//
//  SliderView.swift
//  SuperPaint
//
//  Created by Stanislav on 05/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

final class SliderView: UIView
{
	let nameLabel = UILabel()
	let slider = UISlider()
	let valueLabel = UILabel()

	init(defaultValue: NSNumber,
		 minValue: NSNumber,
		 maxValue: NSNumber,
		 parameterName: String) {
		super.init(frame: .zero)
		setupInitialState()
		slider.value = defaultValue.floatValue
		slider.maximumValue = maxValue.floatValue
		slider.minimumValue = minValue.floatValue
		nameLabel.text = parameterName
		valueLabel.text = String(format: "%.1f", defaultValue.floatValue)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension SliderView
{
	func setupInitialState() {
		slider.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		valueLabel.translatesAutoresizingMaskIntoConstraints = false
		slider.addTarget(self, action: #selector(moveSlider), for: .valueChanged)
		nameLabel.font = UIFont.systemFont(ofSize: 13)
		valueLabel.font = UIFont.systemFont(ofSize: 13)
		self.addSubview(nameLabel)
		self.addSubview(slider)
		self.addSubview(valueLabel)
		NSLayoutConstraint.activate([
			nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			nameLabel.topAnchor.constraint(equalTo: self.topAnchor),
			valueLabel.topAnchor.constraint(equalTo: self.topAnchor),
			valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
			nameLabel.widthAnchor.constraint(equalTo: valueLabel.widthAnchor),
			nameLabel.heightAnchor.constraint(equalTo: valueLabel.heightAnchor),
			slider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			slider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			slider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			slider.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
			slider.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
		])
	}

	@objc func moveSlider(_ sender: UISlider) {
		let step: Float = 0.1
		let roundedValue = round(sender.value / step) * step
		sender.value = roundedValue
		valueLabel.text = String(format: "%.1f", sender.value)
	}
}
