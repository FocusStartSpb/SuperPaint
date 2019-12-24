//
//  ICDImageModelManager.swift
//  SuperPaint
//
//  Created by Иван Медведев on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

protocol ICDImageModelManager
{
	func loadImages(completion: (ImagesResult) -> Void)
	func saveImage(_ image: ImageModel)
	func deleteImages(_ images: [ImageModel])
	func saveContext()
}
