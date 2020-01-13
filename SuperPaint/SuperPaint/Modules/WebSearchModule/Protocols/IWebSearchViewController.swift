//
//  IWebSearchViewController.swift
//  SuperPaint
//
//  Created by Иван Медведев on 08/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

protocol IWebSearchViewController: AnyObject
{
	var navController: UINavigationController? { get }
	var searchBarText: String? { get }

	func reloadView(itemsCount: Int)
}
