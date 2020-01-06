//
//  IImageEditorPresenter.swift
//  SuperPaint
//
//  Created by Stanislav on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

protocol IImageEditorPresenter: AnyObject
{
	var currentId: String { get }
	var currentImage: UIImage { get }
	var newImage: Bool { get }
	var filteredPreviews: [UIImage] { get }
	var numberOfPreviews: Int { get }
	var numberOfInstruments: Int { get }
	var filtersList: [Filter] { get }
	var instrumentsList: [Filter] { get }
	var imageEdited: Bool { get }

	func inject(view: IImageEditorViewController)
	func triggerViewReadyEvent()
	func applyFilter(filterIndex: Int)
	func applyInstrument(instrument: Filter, parameter: FilterParameter, newValue: Float)
	func undoAction()
	func getCurrentInstrumentParameters(instrumentIndex: Int) -> [FilterParameter]

	func saveImage()
	func moveBack()
}
