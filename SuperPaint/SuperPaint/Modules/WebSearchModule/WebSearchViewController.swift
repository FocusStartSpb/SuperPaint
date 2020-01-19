//
//  WebSearchViewController.swift
//  SuperPaint
//
//  Created by Иван Медведев on 08/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

final class WebSearchViewController: UIViewController
{
	private let presenter: IWebSearchPresenter
	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = UIConstants.spacingBetweenCellsWeb
		layout.minimumInteritemSpacing = UIConstants.spacingBetweenCellsWeb
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		return collectionView
	}()
	private let searchController = UISearchController(searchResultsController: nil)
	private var safeArea = UILayoutGuide()
	private let imagePlaceholderStack = UIStackView()
	private let imagePlaceholderView = UIImageView()
	private let imagePlaceholderLabel = UILabel()
	private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
	private let activityIndicatorContainer = UIView(frame: .zero)
	private let notFoundStack = UIStackView()
	private let notFoundView = UIImageView()
	private let notFoundLabel = UILabel()

	private var loadingView: CollectionViewActivityIndicator?
	private var showBottomIndicator = false
	private var currentPage = 1

	init(presenter: IWebSearchPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		self.safeArea = self.view.layoutMarginsGuide
		self.setupSettingsForNavigationBar()
		self.setupSearchController()
		self.setupCollectionView()
		self.setupImagePlaceholderStack()
		self.setupNotFoundStack()
		self.setupActivityIndicator()
		self.navigationItem.hidesSearchBarWhenScrolling = false
	}
}

private extension WebSearchViewController
{
	// MARK: Настраиваем navigation bar
	func setupSettingsForNavigationBar() {
		self.navigationItem.searchController = self.searchController
	}

	// MARK: Настраиваем search controller
	func setupSearchController() {
		self.searchController.searchBar.delegate = self
		self.searchController.obscuresBackgroundDuringPresentation = false
		self.definesPresentationContext = true

		let searchBar = self.searchController.searchBar.value(forKey: "searchField") as? UITextField
		searchBar?.textColor = UIConstants.searchBarTextColorWebScreen
	}

	// MARK: Настраиваем collection view
	func setupCollectionView() {
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.register(WebImageCell.self,
									 forCellWithReuseIdentifier: WebImageCell.cellReuseIdentifier)
		self.collectionView.register(CollectionViewActivityIndicator.self,
									 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
									 withReuseIdentifier: CollectionViewActivityIndicator.cellReuseIdentifier)
		self.view.addSubview(self.collectionView)
		self.collectionView.translatesAutoresizingMaskIntoConstraints = false
		self.collectionView.alwaysBounceVertical = true
		self.collectionView.backgroundColor = .white
		NSLayoutConstraint.activate([
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.topAnchor.constraint(equalTo: self.safeArea.topAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.safeArea.bottomAnchor),
		])
	}

	// MARK: Создаем заглушку "Find beautiful photos..."
	func setupImagePlaceholderStack() {
		self.imagePlaceholderStack.addArrangedSubview(self.imagePlaceholderView)
		self.imagePlaceholderStack.addArrangedSubview(self.imagePlaceholderLabel)
		self.view.addSubview(self.imagePlaceholderStack)

		self.imagePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
		self.imagePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
		self.imagePlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false

		self.imagePlaceholderLabel.numberOfLines = 0
		self.imagePlaceholderLabel.textAlignment = .center
		self.imagePlaceholderLabel.text = "Find beautiful photos..."
		self.imagePlaceholderLabel.font = Fonts.thonburi18
		self.imagePlaceholderLabel.textColor = .lightGray

		self.imagePlaceholderView.image = UIImage(named: "image_placeholder")
		self.imagePlaceholderView.contentMode = .scaleAspectFit

		self.imagePlaceholderStack.alignment = .center
		self.imagePlaceholderStack.axis = .vertical
		self.imagePlaceholderStack.distribution = .fill

		NSLayoutConstraint.activate([
			self.imagePlaceholderStack.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
			self.imagePlaceholderStack.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),

			self.imagePlaceholderView.widthAnchor.constraint(equalToConstant: UIConstants.imagePlaceholderSize),
			self.imagePlaceholderView.heightAnchor.constraint(equalToConstant: UIConstants.imagePlaceholderSize),

			self.imagePlaceholderLabel.widthAnchor.constraint(equalTo: self.collectionView.widthAnchor,
															  multiplier: 5 / 6),
		])
	}

	// MARK: Создаем заглушку "Not found"
	func setupNotFoundStack() {
		self.notFoundStack.addArrangedSubview(self.notFoundView)
		self.notFoundStack.addArrangedSubview(self.notFoundLabel)
		self.view.addSubview(self.notFoundStack)

		self.notFoundStack.translatesAutoresizingMaskIntoConstraints = false
		self.notFoundView.translatesAutoresizingMaskIntoConstraints = false
		self.notFoundLabel.translatesAutoresizingMaskIntoConstraints = false

		self.notFoundLabel.numberOfLines = 2
		self.notFoundLabel.textAlignment = .center
		self.notFoundLabel.font = Fonts.thonburi18
		self.notFoundLabel.textColor = .lightGray

		self.notFoundView.image = UIImage(named: "not_found")
		self.notFoundView.contentMode = .scaleAspectFit

		self.notFoundStack.alignment = .center
		self.notFoundStack.axis = .vertical
		self.notFoundStack.distribution = .fill

		self.notFoundStack.isHidden = true

		NSLayoutConstraint.activate([
			self.notFoundStack.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
			self.notFoundStack.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),

			self.notFoundView.widthAnchor.constraint(equalToConstant: UIConstants.notFoundImageSize),
			self.notFoundView.heightAnchor.constraint(equalToConstant: UIConstants.notFoundImageSize),

			self.notFoundLabel.widthAnchor.constraint(equalTo: self.collectionView.widthAnchor,
													  multiplier: 5 / 6),
		])
	}

	// MARK: Создаем индикатор для загрузки с search bar
	func setupActivityIndicator() {
		self.view.addSubview(self.activityIndicatorContainer)
		self.activityIndicatorContainer.addSubview(self.activityIndicator)

		self.activityIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
		self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false

		self.activityIndicatorContainer.layer.cornerRadius = 10
		self.activityIndicatorContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)

		self.activityIndicatorContainer.isHidden = true

		NSLayoutConstraint.activate([
			self.activityIndicatorContainer.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
			self.activityIndicatorContainer.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),
			self.activityIndicatorContainer.widthAnchor.constraint(equalToConstant: UIConstants.activityIndicatorSize),
			self.activityIndicatorContainer.heightAnchor.constraint(equalToConstant: UIConstants.activityIndicatorSize),

			self.activityIndicator.centerXAnchor.constraint(equalTo: self.activityIndicatorContainer.centerXAnchor),
			self.activityIndicator.centerYAnchor.constraint(equalTo: self.activityIndicatorContainer.centerYAnchor),
		])
	}
}

// MARK: - UISearchBarDelegate
extension WebSearchViewController: UISearchBarDelegate
{
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		self.imagePlaceholderStack.isHidden = true
		self.activityIndicator.startAnimating()
		self.activityIndicatorContainer.isHidden = false
		self.presenter.clearImages()
		self.collectionView.reloadData()
		self.showBottomIndicator = false
		self.presenter.loadImages(withSearchText: searchBar.text, page: 1)
		self.currentPage = 1
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.showBottomIndicator = false
	}
}

// MARK: - UICollectionViewDelegate
extension WebSearchViewController: UICollectionViewDelegate
{
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.collectionView.deselectItem(at: indexPath, animated: false)
		let image = self.presenter.getImageAtIndex(index: indexPath.row)
		self.presenter.onCellPressed(image: image)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						referenceSizeForFooterInSection section: Int) -> CGSize {
		if self.showBottomIndicator {
			return CGSize(width: collectionView.bounds.size.width, height: 55)
		}
		else {
			return CGSize.zero
		}
	}

	func collectionView(_ collectionView: UICollectionView,
						viewForSupplementaryElementOfKind kind: String,
						at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionView.elementKindSectionFooter,
			let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																			 withReuseIdentifier: CollectionViewActivityIndicator.cellReuseIdentifier,
																			 for: indexPath) as? CollectionViewActivityIndicator {
			loadingView = footerView
			loadingView?.backgroundColor = UIColor.clear
			return footerView
		}
		return UICollectionReusableView()
	}

	func collectionView(_ collectionView: UICollectionView,
						willDisplaySupplementaryView view: UICollectionReusableView,
						forElementKind elementKind: String,
						at indexPath: IndexPath) {
		let totalPages = self.presenter.getTotalPages()
		if elementKind == UICollectionView.elementKindSectionFooter &&
			self.currentPage >= 1 &&
			self.currentPage <= totalPages {
			self.loadingView?.activityIndicator.startAnimating()
			self.presenter.loadImages(withSearchText: self.searchController.searchBar.text, page: self.currentPage)
		}
	}

	func collectionView(_ collectionView: UICollectionView,
						didEndDisplayingSupplementaryView view: UICollectionReusableView,
						forElementOfKind elementKind: String,
						at indexPath: IndexPath) {
		if elementKind == UICollectionView.elementKindSectionFooter {
			self.loadingView?.activityIndicator.stopAnimating()
		}
	}
}

// MARK: - UICollectionViewDataSource
extension WebSearchViewController: UICollectionViewDataSource
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.presenter.getNumberOfImages()
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = self.collectionView.dequeueReusableCell(
			withReuseIdentifier: WebImageCell.cellReuseIdentifier,
			for: indexPath) as? WebImageCell ?? WebImageCell(frame: .zero)
		cell.imageView.image = self.presenter.getImageAtIndex(index: indexPath.row)
		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WebSearchViewController: UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let totalSpacing = (2 * UIConstants.spacingWeb) + ((UIConstants.numberOfItemsPerRowWeb - 1) *
			UIConstants.spacingBetweenCellsWeb)
		let width = (self.collectionView.bounds.width - totalSpacing) / UIConstants.numberOfItemsPerRowWeb
		return CGSize(width: width, height: width)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		let spacing = UIConstants.spacingWeb
		return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
	}
}

// MARK: - IWebSearchViewController
extension WebSearchViewController: IWebSearchViewController
{
	var navController: UINavigationController? {
		return self.navigationController
	}

	var searchBarText: String? {
		return self.searchController.searchBar.text
	}

	func reloadView(itemsCount: Int) {
		self.activityIndicatorContainer.isHidden = true
		self.activityIndicator.stopAnimating()
		self.collectionView.reloadData()

		if itemsCount == 0 {
			self.notFoundStack.isHidden = false
			if let text = self.searchController.searchBar.text {
				self.notFoundLabel.text = "Nothing found on query \"\(text)\""
			}
		}
		else {
			self.currentPage += 1
			self.notFoundStack.isHidden = true
		}
		if self.currentPage > self.presenter.getTotalPages() {
			self.showBottomIndicator = false
		}
		else {
			self.showBottomIndicator = true
		}
	}
}
