//
//  CDImageModelManager.swift
//  SuperPaint
//
//  Created by Иван Медведев on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import CoreData

typealias ImagesResult = Result<[ImageModel], Error>

private enum ImageModelKeys
{
	static let name = "ImageModel"
	static let id = "id"
	static let imageData = "imageData"
}

final class CDImageModelManager
{
	private lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: ImageModelKeys.name)
		container.loadPersistentStores { _, error in
			if let error = error {
				assertionFailure(error.localizedDescription)
			}
		}
		return container
	}()

	private var managedContext: NSManagedObjectContext {
		return self.persistentContainer.viewContext
	}
}

extension CDImageModelManager: ICDImageModelManager
{
	func loadImages(completion: (ImagesResult) -> Void) {
		let fetchRequest = NSFetchRequest<ImageModel>(entityName: ImageModelKeys.name)
		do {
			let images = try self.managedContext.fetch(fetchRequest)
			completion(.success(images))
		}
		catch {
			completion(.failure(error))
		}
	}

	func saveImage(id: String, data imageData: NSData, completion: (NSManagedObject) -> Void) {
		guard let imageEntity = NSEntityDescription.entity(forEntityName: ImageModelKeys.name,
														   in: self.managedContext) else { return }
		let imageModel = NSManagedObject(entity: imageEntity, insertInto: self.managedContext)
		imageModel.setValue(id, forKey: ImageModelKeys.id)
		imageModel.setValue(imageData, forKey: ImageModelKeys.imageData)

		do {
			try self.managedContext.save()
			completion(imageModel)
		}
		catch {
			assertionFailure(error.localizedDescription)
		}
	}

	func updateImage(id: String, data imageData: NSData, completion: (ImageModel) -> Void) {
		let fetchRequest = NSFetchRequest<ImageModel>(entityName: "ImageModel")
		fetchRequest.predicate = NSPredicate(format: "id = %@", id)

		do {
			let imageModels = try managedContext.fetch(fetchRequest)
			guard let imageToUpdate = imageModels.first else { return }
			imageToUpdate.setValue(imageData, forKey: ImageModelKeys.imageData)
			do {
				try self.managedContext.save()
				completion(imageToUpdate)
			}
			catch {
				assertionFailure(error.localizedDescription)
			}
		}
		catch {
			assertionFailure(error.localizedDescription)
		}
	}

	func deleteImages(_ images: [ImageModel]) {
		let fetchRequest = NSFetchRequest<ImageModel>(entityName: ImageModelKeys.name)
		images.forEach { imageModel in
			guard let id = imageModel.id else { return }
			fetchRequest.predicate = NSPredicate(format: "id = %@", id)

			do {
				let imageModels = try self.managedContext.fetch(fetchRequest)
				guard let imageToDelete = imageModels.first else { return }
				self.managedContext.delete(imageToDelete)
			}
			catch {
				assertionFailure(error.localizedDescription)
			}
		}
		self.saveContext()
	}

	func saveContext() {
		if self.managedContext.hasChanges {
			do {
				try self.managedContext.save()
			}
			catch {
				assertionFailure(error.localizedDescription)
			}
		}
	}
}
