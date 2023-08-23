// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KovaleeAds",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v14)
	],
    products: [
		.library(
			name: "KovaleeAds",
			targets: [
				"KovaleeAds"
			]
		)
    ],
    dependencies: [
		.package(url: "https://github.com/cotyapps/Kovalee-iOS-SDK", from: Version(1, 3, 0)),
		.package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", from: Version(11, 10, 1))
    ],
    targets: [
		.target(
			name: "KovaleeAds",
			dependencies: [
				.product(name: "KovaleeSDK", package: "Kovalee-iOS-SDK"),
				.product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
				"AdColony",
				"AppLovinMediationAdColonyAdapter",
				"AppLovinMediationFacebookAdapter",
				"AppLovinMediationIronSourceAdapter",
				"AppLovinMediationUnityAdsAdapter",
				"FBAudienceNetwork",
				"IronSource",
				"UnityAds"
			]
		),

		.binaryTarget(
			name: "AdColony",
			path: "./Frameworks/AdColony.xcframework"
		),
		.binaryTarget(
			name: "AppLovinMediationAdColonyAdapter",
			path: "./Frameworks/AppLovinMediationAdColonyAdapter.xcframework"
		),
		.binaryTarget(
			name: "AppLovinMediationFacebookAdapter",
			path: "./Frameworks/AppLovinMediationFacebookAdapter.xcframework"
		),
		.binaryTarget(
			name: "AppLovinMediationIronSourceAdapter",
			path: "./Frameworks/AppLovinMediationIronSourceAdapter.xcframework"
		),
		.binaryTarget(
			name: "AppLovinMediationUnityAdsAdapter",
			path: "./Frameworks/AppLovinMediationUnityAdsAdapter.xcframework"
		),
		.binaryTarget(
			name: "FBAudienceNetwork",
			path: "./Frameworks/FBAudienceNetwork.xcframework"
		),
		.binaryTarget(
			name: "IronSource",
			path: "./Frameworks/IronSource.xcframework"
		),
		.binaryTarget(
			name: "UnityAds",
			path: "./Frameworks/UnityAds.xcframework"
		)
    ]
)
