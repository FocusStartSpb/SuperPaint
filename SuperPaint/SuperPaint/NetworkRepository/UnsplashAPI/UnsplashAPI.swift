//
//  UnsplashAPI.swift
//  SuperPaint
//
//  Created by Иван Медведев on 11/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

typealias UnsplashImagesResult = Result<(images: [UIImage], totalPages: Int, query: String?), Error>

enum UnsplashAPIConstants
{
	static let baseURL = "https://api.unsplash.com/"
	static let searchURL = "search/photos"
	static let accessKey = "277c8a87db2709145274a57a9c9ec044b3f19a46366cdd3b696e5b617878c6b3"
}

final class UnsplashAPI
{
	private var task: URLSessionDataTask?

	func loadImages(withSearchText text: String?, page: Int, completion: @escaping (UnsplashImagesResult) -> Void) {
		var resultImages = [UIImage]()
		guard var components = URLComponents(string: UnsplashAPIConstants.baseURL + UnsplashAPIConstants.searchURL) else {
			completion(.failure(NetworkErrors.wrongURL))
			return
		}

		if let text = text {
			components.queryItems = [
				URLQueryItem(name: "query", value: text),
				URLQueryItem(name: "page", value: "\(page)"),
			]
		}

		guard let url = components.url else {
			completion(.failure(NetworkErrors.wrongURL))
			return
		}

		var urlRequest = URLRequest(url: url)
		urlRequest.setValue("Client-ID \(UnsplashAPIConstants.accessKey)",
							forHTTPHeaderField: "Authorization")

		task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
			if let error = error {
				completion(.failure(error))
			}
			if let data = data {
				do {
					let images = try JSONDecoder().decode(UnsplashImages.self, from: data)
					images.results.forEach { unsplashImage in
						if let imageURL = URL(string: unsplashImage.urls.small),
							let imageData = try? Data(contentsOf: imageURL),
							let image = UIImage(data: imageData) {
							resultImages.append(image)
						}
					}
					let totalPages = images.totalPages
					completion(.success((resultImages, totalPages, text)))
				}
				catch {
					completion(.failure(error))
				}
			}
		}
		task?.resume()
	}
}
