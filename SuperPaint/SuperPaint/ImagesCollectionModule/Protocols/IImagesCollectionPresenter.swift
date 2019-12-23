//
//  IImagesCollectionPresenter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

protocol IImagesCollectionPresenter: AnyObject
{
	func onCellPressed(with image: UIImage)
}
