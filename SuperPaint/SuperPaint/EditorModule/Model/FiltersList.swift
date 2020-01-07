//
//  FiltersList.swift
//  SuperPaint
//
//  Created by Stanislav on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//
//swiftlint:disable function_body_length
import Foundation

enum FiltersList: CaseIterable
{
	case chrome
	case fade
	case instant
	case mono
	case noir
	case process
	case tonal
	case transfer
	case sepia
	case invert
	case color
	case exposure

	func getFilter() -> Filter {
		switch self {
		case .chrome:
			return Filter(with: "Chrome", code: "CIPhotoEffectChrome")
		case .fade:
			return Filter(with: "Fade", code: "CIPhotoEffectFade")
		case .instant:
			return Filter(with: "Instant", code: "CIPhotoEffectInstant")
		case .mono:
			return Filter(with: "Mono", code: "CIPhotoEffectMono")
		case .noir:
			return Filter(with: "Noir", code: "CIPhotoEffectNoir")
		case .process:
			return Filter(with: "Process", code: "CIPhotoEffectProcess")
		case .tonal:
			return Filter(with: "Tonal", code: "CIPhotoEffectTonal")
		case .transfer:
			return Filter(with: "Transfer", code: "CIPhotoEffectTransfer")
		case .sepia:
			return Filter(with: "Sepia", code: "CISepiaTone")
		case .invert:
			return Filter(with: "Invert", code: "CIColorInvert")
		case .color:
			return Filter(with: "Color",
						  code: "CIColorControls",
						  parameters: [
							FilterParameter(name: "Saturation",
											code: "inputSaturation",
											defaultValue: 1.0,
											minValue: 0,
											maxValue: 2.0),
							FilterParameter(name: "Brightness",
											code: "inputBrightness",
											defaultValue: 0.0,
											minValue: 0,
											maxValue: 1.0),
							FilterParameter(name: "Contrast",
											code: "inputContrast",
											defaultValue: 1.0,
											minValue: 0,
											maxValue: 5.0),
						])
		case .exposure:
			return Filter(with: "Exposure", code: "CIExposureAdjust", parameters: [
				FilterParameter(name: "EV",
								code: "inputEV",
								defaultValue: 0.5,
								minValue: 0,
								maxValue: 1.0),
			])
		}
	}
}
