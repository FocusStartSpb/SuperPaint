//
//  ImageEditorRouter.swift
//  SuperPaint
//
//  Created by Stanislav on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

final class ImageEditorRouter
{
	private weak var view: IImageEditorViewController?
	private let factory: ModuleFactory

	init(factory: ModuleFactory) {
		self.factory = factory
	}
}

extension ImageEditorRouter: IImageEditorRouter
{
	func inject(view: IImageEditorViewController) {
		self.view = view
	}

	func moveBack() {
		self.view?.navController?.popViewController(animated: true)
	}
}
