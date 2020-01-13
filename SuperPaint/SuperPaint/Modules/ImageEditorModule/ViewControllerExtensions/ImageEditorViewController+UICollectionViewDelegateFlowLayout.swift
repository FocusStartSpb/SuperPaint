//
//  ImageEditorViewController+UICollectionViewDelegateFlowLayout.swift
//  SuperPaint
//
//  Created by Stanislav on 13/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension ImageEditorViewController: UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == filtersCollection {
			return CGSize(width: UIConstants.collectionViewCellWidth * 0.7,
						  height: UIConstants.filterCollectionViewCellHeight * 0.7)
		}
		else {
			return CGSize(width: UIConstants.collectionViewCellWidth,
						  height: UIConstants.instrumentCollectionViewCellHeight * 0.9)
		}
	}
}
