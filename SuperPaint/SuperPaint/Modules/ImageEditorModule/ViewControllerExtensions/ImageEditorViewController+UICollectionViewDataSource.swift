//
//  ImageEditorViewController+UICollectionViewDataSource.swift
//  SuperPaint
//
//  Created by Stanislav on 13/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

extension ImageEditorViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == filtersCollection {
			return presenter.numberOfPreviews
		}
		else {
			return presenter.numberOfInstruments
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == filtersCollection {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.cellReuseIdentifier,
														  for: indexPath) as? FilterCell ?? FilterCell(frame: .zero)
			cell.imageView.image = presenter.filteredPreviews[indexPath.row]
			cell.label.text = presenter.filtersList[indexPath.row].name
			return cell
		}
		else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InstrumentCell.cellReuseIdentifier,
														  for: indexPath) as? InstrumentCell ?? InstrumentCell(frame: .zero)
			cell.label.text = presenter.instrumentsList[indexPath.row].name
			return cell
		}
	}
}
