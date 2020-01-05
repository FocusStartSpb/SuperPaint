//
//  FiltersList.swift
//  SuperPaint
//
//  Created by Stanislav on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//

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
							FilterParameter(parameterName: "inputSaturation", defaultValue: 1.0),
							FilterParameter(parameterName: "inputBrightness", defaultValue: 0.0),
							FilterParameter(parameterName: "inputContrast", defaultValue: 1.0),
						])
		}
	}
}
