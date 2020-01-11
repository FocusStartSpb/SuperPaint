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
	private let presenter: IImageEditorPresenter
	private let nameLabel = UILabel()
	private let slider = UISlider()
	private let valueLabel = UILabel()
	private let parameter: FilterParameter
	private let instrument: Filter
	private var safeArea = UILayoutGuide()

	init(presenter: IImageEditorPresenter, instrument: Filter, parameter: FilterParameter) {
		self.presenter = presenter
		self.instrument = instrument
		self.parameter = parameter
		super.init(frame: .zero)
		setupInitialState()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension SliderView
{
	func setupInitialState() {
		safeArea = self.layoutMarginsGuide
		slider.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		valueLabel.translatesAutoresizingMaskIntoConstraints = false
		slider.addTarget(self, action: #selector(moveSlider), for: .valueChanged)
		nameLabel.font = Fonts.sliderFont
		nameLabel.textColor = UIConstants.textColor
		valueLabel.font = Fonts.sliderFont
		valueLabel.textColor = UIConstants.valueColor
		valueLabel.textAlignment = .right
		self.addSubview(nameLabel)
		self.addSubview(slider)
		self.addSubview(valueLabel)
		NSLayoutConstraint.activate([
			nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			nameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
			valueLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
			valueLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
			nameLabel.widthAnchor.constraint(equalTo: valueLabel.widthAnchor),
			nameLabel.heightAnchor.constraint(equalTo: valueLabel.heightAnchor),
			slider.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			slider.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
			slider.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
			slider.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
			slider.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
		])
		slider.value = parameter.defaultValue.floatValue
		slider.maximumValue = parameter.maxValue.floatValue
		slider.minimumValue = parameter.minValue.floatValue
		nameLabel.text = parameter.name
		valueLabel.text = String(format: "%.1f", parameter.defaultValue.floatValue)
	}

	@objc func moveSlider(slider: UISlider, event: UIEvent) {
		let step: Float = 0.1
		let roundedValue = round(slider.value / step) * step
		if let touchEvent = event.allTouches?.first {
			switch touchEvent.phase {
			case .moved:
				slider.value = roundedValue
				valueLabel.text = String(format: "%.1f", slider.value)
			case .ended:
				presenter.applyInstrument(instrument: instrument, parameter: parameter, newValue: roundedValue)
			default:
				break
			}
		}
	}
}
