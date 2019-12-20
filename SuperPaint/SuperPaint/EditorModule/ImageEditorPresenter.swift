//
//  ImageEditorPresenter.swift
//  SuperPaint
//
//  Created by Stanislav on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

final class ImageEditorPresenter
{
	private let router: IImageEditorRouter
	private let repository: IRepository
	private weak var view: IImageEditorViewController?

	init(router: IImageEditorRouter, repository: IRepository) {
		self.router = router
		self.repository = repository
	}
}

extension ImageEditorPresenter: IImageEditorPresenter
{
	func inject(view: IImageEditorViewController) {
		self.view = view
	}
}
