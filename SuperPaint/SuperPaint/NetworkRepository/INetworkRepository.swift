//
//  IRepository.swift
//  SuperPaint
//
//  Created by Иван Медведев on 18/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

import Foundation

protocol INetworkRepository: AnyObject
{
	func loadImages(withSearchText text: String?, page: Int, completion: @escaping (UnsplashImagesResult) -> Void)
}
