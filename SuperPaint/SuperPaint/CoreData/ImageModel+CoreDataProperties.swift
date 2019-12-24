//
//  ImageModel+CoreDataProperties.swift
//  SuperPaint
//
//  Created by Иван Медведев on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//
//

import Foundation
import CoreData

extension ImageModel
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ImageModel> {
		return NSFetchRequest<ImageModel>(entityName: "ImageModel")
	}

	@NSManaged public var image: NSData?
	@NSManaged public var id: String?
}
