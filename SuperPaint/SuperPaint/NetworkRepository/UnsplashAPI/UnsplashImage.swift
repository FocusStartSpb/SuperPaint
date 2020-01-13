//
//  UnsplashImage.swift
//  SuperPaint
//
//  Created by Иван Медведев on 11/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import Foundation

struct UnsplashImages: Decodable
{
	let totalPages: Int
	let results: [UnsplashImage]

	enum CodingKeys: String, CodingKey
	{
		case totalPages = "total_pages"
		case results
	}
}

struct UnsplashImage: Decodable
{
	let id: String
	let width: Int
	let height: Int
	let likes: Int
	let color: String
	let urls: URLs
	let keyNotExist: String?
}

struct URLs: Decodable
{
	let raw: String
	let full: String
	let regular: String
	let small: String
	let thumb: String
}
