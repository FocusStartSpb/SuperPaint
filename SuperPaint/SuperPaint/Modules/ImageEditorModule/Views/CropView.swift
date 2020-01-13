//
//  CropView.swift
//  SuperPaint
//
//  Created by Stanislav on 12/01/2020.
//  Copyright © 2020 Fixiki. All rights reserved.
//

import UIKit

final class CropView: UIView
{
	enum Edge
	{
		case topLeft, topRight, bottomLeft, bottomRight, none
	}

	enum Side
	{
		case left, top, right, bottom, none
	}

	let originalFrame: CGRect
	static var touchPrecision: CGFloat = UIConstants.cropTouchPrecision
	var currentSide: Side = .none
	var touchLocation = CGPoint.zero

	override init(frame: CGRect) {
		originalFrame = frame
		super.init(frame: frame)
		setupInitialState()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {

			touchLocation = touch.location(in: self)
//Определяем за какую сторону тянем
			currentSide = {
				if touchLocation.y < CropView.touchPrecision {
					return .top
				}
				else if self.bounds.size.height - touchLocation.y < CropView.touchPrecision {
					return .bottom
				}
				else if touchLocation.x < CropView.touchPrecision {
					return .left
				}
				else if self.bounds.size.width - touchLocation.x < CropView.touchPrecision {
					return .right
				}
				return .none
			}()
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
//Меняем размер вьюхи
			let currentLocation = touch.location(in: self)
			let previousLocation = touch.previousLocation(in: self)

			let deltaWidth = currentLocation.x - previousLocation.x
			let deltaHeight = currentLocation.y - previousLocation.y

			switch currentSide {
			case .top:
				if originalFrame.origin.y < self.frame.origin.y + deltaHeight {
					self.frame.size.height -= deltaHeight
					self.frame.origin.y += deltaHeight
				}
			case .left:
				if originalFrame.origin.x < self.frame.origin.x + deltaWidth {
					self.frame.size.width -= deltaWidth
					self.frame.origin.x += deltaWidth
				}
			case .right:
				if originalFrame.origin.x + originalFrame.width > self.frame.origin.x + self.frame.size.width + deltaWidth {
					self.frame.size.width += deltaWidth
				}
			case .bottom:
				if originalFrame.origin.y + originalFrame.height > self.frame.origin.y + self.frame.size.height + deltaHeight {
					self.frame.size.height += deltaHeight
				}
			default:
				break
			}
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		currentSide = .none
	}
}
private extension CropView
{
	func setupInitialState() {
		self.layer.borderWidth = 3.0
		self.layer.borderColor = UIConstants.systemButtonColor.cgColor
		self.backgroundColor = .clear
	}
}
