//
//  IImagesCollectionRouter.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import UIKit

protocol IImagesCollectionRouter: AnyObject
{
	func pushEditorModule(id: String, data: NSData, isNewImage: Bool)
	func pushWebSearchModule()
}
