//
//  IImageEditorRouter.swift
//  SuperPaint
//
//  Created by Stanislav on 20/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

protocol IImageEditorRouter: AnyObject
{
	func inject(view: IImageEditorViewController)
}
