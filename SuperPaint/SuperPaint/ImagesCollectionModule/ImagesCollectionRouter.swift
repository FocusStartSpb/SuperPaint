//
//  ImagesCollectionRouter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImagesCollectionRouter
{
	weak var imagesCollectionView: IImagesCollectionViewController?
	private let factory: ModuleFactory

	init(factory: ModuleFactory) {
		self.factory = factory
	}

	func inject(view: IImagesCollectionViewController) {
		self.imagesCollectionView = view
	}
}

extension ImagesCollectionRouter: IImagesCollectionRouter
{
	func pushEditorModule(id: String, data: NSData, isNewImage: Bool) {
		guard let image = UIImage(data: data as Data) else { return }
		let vc = self.factory.createImageEditorModule(id: id, image: image, isNewImage: isNewImage)
		self.imagesCollectionView?.navController?.pushViewController(vc, animated: true)
	}
}
