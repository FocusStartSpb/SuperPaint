//
//  ImageEditorViewController+UICollectionViewDelegate.swift
//  SuperPaint
//
//  Created by Stanislav on 13/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension ImageEditorViewController: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
		if collectionView == filtersCollection {
			presenter.applyFilter(filterIndex: indexPath.row)
		}
		else {
			showSliders(instrumentIndex: indexPath.row)
			selectedInstrumentIndex = indexPath.row
		}
	}
}
