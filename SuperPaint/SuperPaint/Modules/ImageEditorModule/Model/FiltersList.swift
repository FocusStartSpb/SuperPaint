//
//  FiltersList.swift
//  SuperPaint
//
//  Created by Stanislav on 24/12/2019.
//  Copyright © 2019 Fixiki. All rights reserved.
//
//swiftlint:disable function_body_length

import UIKit

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
	case comic
	case color
	case exposure
	case gaussianBlur
	case noiseReduction
	case motionBlur
	case gammaAdjust
	case hueAdjust
	case colorPosterize
	case vignette
	case sharpenLuminance
	case bloom
	case edges
	case gloom
	case crop

	func getFilter() -> Filter {
		switch self {
		case .chrome:
			return Filter(with: "Chrome", code: "CIPhotoEffectChrome", actionType: .filter)
		case .fade:
			return Filter(with: "Fade", code: "CIPhotoEffectFade", actionType: .filter)
		case .instant:
			return Filter(with: "Instant", code: "CIPhotoEffectInstant", actionType: .filter)
		case .mono:
			return Filter(with: "Mono", code: "CIPhotoEffectMono", actionType: .filter)
		case .noir:
			return Filter(with: "Noir", code: "CIPhotoEffectNoir", actionType: .filter)
		case .process:
			return Filter(with: "Process", code: "CIPhotoEffectProcess", actionType: .filter)
		case .tonal:
			return Filter(with: "Tonal", code: "CIPhotoEffectTonal", actionType: .filter)
		case .transfer:
			return Filter(with: "Transfer", code: "CIPhotoEffectTransfer", actionType: .filter)
		case .sepia:
			return Filter(with: "Sepia", code: "CISepiaTone", actionType: .filter)
		case .invert:
			return Filter(with: "Invert", code: "CIColorInvert", actionType: .filter)
		case .comic:
			return Filter(with: "Comic", code: "CIComicEffect", actionType: .filter)
		case .color:
			return Filter(with: "Color",
						  code: "CIColorControls",
						  actionType: .instrument,
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
			return Filter(with: "Exposure",
						  code: "CIExposureAdjust",
						  actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Value",
								code: "inputEV",
								defaultValue: 0.5,
								minValue: 0,
								maxValue: 1.0),
			])
		case .gaussianBlur:
			return Filter(with: "Gaussian Blur",
						  code: "CIGaussianBlur",
						  actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Radius",
								code: "inputRadius",
								defaultValue: 0,
								minValue: 0,
								maxValue: 20),
			])
		case .noiseReduction:
			return Filter(with: "Noise Reduction", code: "CINoiseReduction", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Level", code: "inputNoiseLevel", defaultValue: 0.02, minValue: 0, maxValue: 1),
				FilterParameter(name: "Sharpness", code: "inputSharpness", defaultValue: 0.4, minValue: 0, maxValue: 1),
			])
		case .motionBlur:
			return Filter(with: "Motion Blur", code: "CIMotionBlur", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 0, minValue: 0, maxValue: 20),
				FilterParameter(name: "Angle", code: "inputAngle", defaultValue: 0, minValue: 0, maxValue: 100),
			])
		case .gammaAdjust:
			return Filter(with: "Gamma Adjust", code: "CIGammaAdjust", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Power",
								code: "inputPower",
								defaultValue: 0.75,
								minValue: 0,
								maxValue: 5),
			])
		case .hueAdjust:
			return Filter(with: "Hue Adjust", code: "CIHueAdjust", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Angle",
								code: "inputAngle",
								defaultValue: 0,
								minValue: 0,
								maxValue: 2),
			])
		case .colorPosterize:
			return Filter(with: "Posterize", code: "CIColorPosterize", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Levels",
								code: "inputLevels",
								defaultValue: 6,
								minValue: 2,
								maxValue: 20),
			])
		case .vignette:
			return Filter(with: "Vignette", code: "CIVignette", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 1, minValue: 0, maxValue: 2),
				FilterParameter(name: "Intensity", code: "inputIntensity", defaultValue: 0, minValue: 0, maxValue: 30),
			])
		case .sharpenLuminance:
			return Filter(with: "Sharpen Luminance", code: "CISharpenLuminance", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Sharpness",
								code: "inputSharpness",
								defaultValue: 0.4,
								minValue: 0,
								maxValue: 100),
			])
		case .bloom:
			return Filter(with: "Bloom", code: "CIBloom", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 10, minValue: 0, maxValue: 100),
				FilterParameter(name: "Intensity", code: "inputIntensity", defaultValue: 0.5, minValue: 0, maxValue: 5),
			])
		case .edges:
			return Filter(with: "Edges", code: "CIEdges", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Intensity",
								code: "inputIntensity",
								defaultValue: 1,
								minValue: 0.4,
								maxValue: 2),
			])
		case .gloom:
			return Filter(with: "Gloom", code: "CIGloom", actionType: .instrument,
						  parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 10, minValue: 0, maxValue: 100),
				FilterParameter(name: "Intensity", code: "inputIntensity", defaultValue: 0.5, minValue: 0, maxValue: 5),
			])
		case .crop:
			return Filter(with: "Crop", code: "CICrop", actionType: .crop,
					  parameters: [
			FilterParameter(name: "Rectangle",
							code: "inputRectangle",
							defaultValue: CIVector(cgRect: .zero),
							minValue: 0,
							maxValue: 0),
			])
		}
	}
}
