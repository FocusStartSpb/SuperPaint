//
//  ImagesCollectionViewController.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

final class ImagesCollectionViewController: UIViewController
{
	private let imagesCollectionPresenter: IImagesCollectionPresenter

	init(presenter: IImagesCollectionPresenter) {
		self.imagesCollectionPresenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

extension ImagesCollectionViewController: IImagesCollectionViewController
{
}
