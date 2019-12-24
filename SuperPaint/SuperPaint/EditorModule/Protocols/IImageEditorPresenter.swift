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
	var currentImage: UIImage { get }
	var filteredPreviews: [UIImage] { get }
	var numberOfPreviews: Int { get }
	var filtersList: [Filter] { get }

	func inject(view: IImageEditorViewController)
	func triggerViewReadyEvent()
	func applyFilter(image: UIImage, filterIndex: Int)
	func undoAction()
}
