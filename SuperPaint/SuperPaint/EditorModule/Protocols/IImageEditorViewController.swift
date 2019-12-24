//
//  IImageEditorViewController.swift
//  SuperPaint
//
//  Created by Stanislav on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

protocol IImageEditorViewController: AnyObject
{
	func stopSpinner()
	func startSpinner()
	func refreshButtonsState(imagesStackIsEmpty: Bool)
	func setImage(image: UIImage)
}
