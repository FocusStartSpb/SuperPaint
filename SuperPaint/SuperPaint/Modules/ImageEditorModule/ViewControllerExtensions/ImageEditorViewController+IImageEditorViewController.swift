//
//  ImageEditorViewController+IImageEditorViewController.swift
//  SuperPaint
//
//  Created by Stanislav on 13/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension ImageEditorViewController: IImageEditorViewController
{
	func stopSpinner() {
		spinner.stopAnimating()
	}

	func startSpinner() {
		spinner.startAnimating()
	}

	var userInteractionEnabled: Bool {
		get {
			return self.view.isUserInteractionEnabled
		}
		set {
			self.view.isUserInteractionEnabled = newValue
			self.navigationController?.navigationBar.isUserInteractionEnabled = newValue
		}
	}

	func refreshButtonsState(imagesStackIsEmpty: Bool) {
		undoButton?.isEnabled = imagesStackIsEmpty ? false : true
		saveButton?.isEnabled = imagesStackIsEmpty ? false : true
	}

	func setImage(image: UIImage) {
		imageView.image = image
	}

	var navController: UINavigationController? {
		return self.navigationController
	}

	//Обновить значения слайдеров текущими значениями
	func refreshSlidersValues() {
		presenter.instrumentsList.forEach { instrument in
			for (index, parameter) in instrument.parameters.enumerated() {
				if let sliderViewArray = sliders[instrument.name],
					let sliderView = sliderViewArray[index] as? SliderView {
					sliderView.setSliderValue(value: parameter.currentValue.floatValue)
				}
			}
		}
	}

	func reloadFilterPreviews() {
		filtersCollection.reloadData()
	}
}
