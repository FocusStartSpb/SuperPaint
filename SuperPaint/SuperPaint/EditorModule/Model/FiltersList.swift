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
		case .comic:
			return Filter(with: "Comic", code: "CIComicEffect")
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
		case .gaussianBlur:
			return Filter(with: "Gaussian Blur", code: "CIGaussianBlur", parameters: [
				FilterParameter(name: "Radius",
								code: "inputRadius",
								defaultValue: 10.0,
								minValue: 0,
								maxValue: 20),
			])
		case .noiseReduction:
			return Filter(with: "Noise Reduction", code: "CINoiseReduction", parameters: [
				FilterParameter(name: "Level", code: "inputNoiseLevel", defaultValue: 0.02, minValue: 0, maxValue: 1),
				FilterParameter(name: "Sharpness", code: "inputSharpness", defaultValue: 0.4, minValue: 0, maxValue: 1),
			])
		case .motionBlur:
			return Filter(with: "Motion Blur", code: "CIMotionBlur", parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 20, minValue: 0, maxValue: 100),
				FilterParameter(name: "Angle", code: "inputAngle", defaultValue: 0, minValue: 0, maxValue: 100),
			])
		case .gammaAdjust:
			return Filter(with: "Gamma Adjust", code: "CIGammaAdjust", parameters: [
				FilterParameter(name: "Power",
								code: "inputPower",
								defaultValue: 0.75,
								minValue: 0,
								maxValue: 5),
			])
		case .hueAdjust:
			return Filter(with: "Hue Adjust", code: "CIHueAdjust", parameters: [
				FilterParameter(name: "Angle",
								code: "inputAngle",
								defaultValue: 0,
								minValue: 0,
								maxValue: 100),
			])
		case .colorPosterize:
			return Filter(with: "Posterize", code: "CIColorPosterize", parameters: [
				FilterParameter(name: "Levels",
								code: "inputLevels",
								defaultValue: 6,
								minValue: 2,
								maxValue: 20),
			])
		case .vignette:
			return Filter(with: "Vignette", code: "CIVignette", parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 1, minValue: 0, maxValue: 2),
				FilterParameter(name: "Intensity", code: "inputIntensity", defaultValue: 0, minValue: 0, maxValue: 30),
			])
		case .sharpenLuminance:
			return Filter(with: "Sharpen Luminance", code: "CISharpenLuminance", parameters: [
				FilterParameter(name: "Sharpness",
								code: "inputSharpness",
								defaultValue: 0.4,
								minValue: 0,
								maxValue: 100),
			])
		case .bloom:
			return Filter(with: "Bloom", code: "CIBloom", parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 10, minValue: 0, maxValue: 100),
				FilterParameter(name: "Intensity", code: "inputIntensity", defaultValue: 0.5, minValue: 0, maxValue: 5),
			])
		case .edges:
			return Filter(with: "Edges", code: "CIEdges", parameters: [
				FilterParameter(name: "Intensity",
								code: "inputIntensity",
								defaultValue: 1,
								minValue: 0.4,
								maxValue: 2),
			])
		case .gloom:
			return Filter(with: "Gloom", code: "CIGloom", parameters: [
				FilterParameter(name: "Radius", code: "inputRadius", defaultValue: 10, minValue: 0, maxValue: 100),
				FilterParameter(name: "Intensity", code: "inputIntensity", defaultValue: 0.5, minValue: 0, maxValue: 5),
			])
		}
	}
}
