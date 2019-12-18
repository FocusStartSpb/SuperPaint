//
//  ImagesCollectionRouter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

final class ImagesCollectionRouter
{
	weak var imagesCollectionView: IImagesCollectionViewController?

	func inject(view: IImagesCollectionViewController) {
		self.imagesCollectionView = view
	}
}

extension ImagesCollectionRouter: IImagesCollectionRouter
{
}
