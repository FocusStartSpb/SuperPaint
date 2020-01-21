//
//  ICDImageModelManager.swift
//  SuperPaint
//
//  Created by Иван Медведев on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation
import CoreData

protocol ICDImageModelManager: AnyObject
{
	func loadImages(completion: (ImagesResult) -> Void)
	func saveImage(id: String, data imageData: NSData, completion: (ImageModel) -> Void)
	func updateImage(id: String, data imageData: NSData, completion: (ImageModel) -> Void)
	func deleteImages(_ images: [ImageModel])
	func saveContext()
}
