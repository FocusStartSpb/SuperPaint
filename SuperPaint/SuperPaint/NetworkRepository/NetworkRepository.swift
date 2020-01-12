//
//  Repository.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

final class NetworkRepository
{
	private let unsplashAPI = UnsplashAPI()
}

extension NetworkRepository: INetworkRepository
{
	func loadImages(withSearchText text: String?, page: Int, completion: @escaping (UnsplashImagesResult) -> Void) {
		self.unsplashAPI.loadImages(withSearchText: text, page: page) { unsplashImagesResult in
			switch unsplashImagesResult {
			case .success(let result):
				completion(.success(result))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
