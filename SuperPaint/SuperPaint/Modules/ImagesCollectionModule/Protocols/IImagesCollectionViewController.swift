//
//  IImagesCollectionViewController.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

protocol IImagesCollectionViewController: AnyObject
{
	var navController: UINavigationController? { get }

	func reloadView()
	func saveNewImage(newImageModel: ImageModel)
	func updateImage(imageModel: ImageModel)
}
