import AppLovinSDK
import FBAudienceNetwork
import KovaleeFramework
import KovaleeSDK

enum ApplovinError: Error {
	case notInitializedCorrectly
}

class ApplovinWrapperImpl: NSObject, AdsManager, Manager {
    init(withKey key: KovaleeKeys.Applovin) {
		KLogger.debug("📺 initializing Applovin")

        self.key = key
        self.sdk = ALSdk.shared(withKey: key.sdkId)
        self.sdk?.mediationProvider = "max"
        self.sdk?.settings.isVerboseLoggingEnabled = KLogger.logLevel.applovinLogLevel()

		self.interstitialUnitId = key.interstitialUnitId
		self.rewardedUnitId = key.rewardedUnitId
    }
	
	private func checkSDKInitialization() async throws {
		guard let sdk = self.sdk else {
			KLogger.error("📺 Couldn't initialize Applovin")
			throw ApplovinError.notInitializedCorrectly
		}

		if !sdk.isInitialized {
			self.configuration = await sdk.initializeSdk()
			self.setupfbAdProcessingOptions()
		}

		if self.interstitialAd == nil {
			self.interstitialAd = MAInterstitialAd(
				adUnitIdentifier: key.interstitialUnitId,
				sdk: sdk
			)
		}

		if self.rewardedAd == nil {
			self.rewardedAd = MARewardedAd.shared(
				withAdUnitIdentifier: key.rewardedUnitId,
				sdk: sdk
			)
		}

		KLogger.debug("📺 Applovin initialized correctly")
	}

	func setupfbAdProcessingOptions() {
        if configuration?.appTrackingTransparencyStatus == .authorized {
            FBAdSettings.setAdvertiserTrackingEnabled(true)
        }

		FBAdSettings.setDataProcessingOptions(["LDU"], country: 0, state: 0)
    }

	func createInterstitialAd() async throws -> Bool {
		try await checkSDKInitialization()

		return try await withCheckedThrowingContinuation { continuation in
			interstitialAdReady = continuation
			interstitialAd?.delegate = self
			interstitialAd?.load()
		}
    }

    func createRewardedAd() async throws -> Bool {
		try await checkSDKInitialization()

		return try await withCheckedThrowingContinuation { continuation in
			rewardedAdReady = continuation
			rewardedAd?.delegate = self
			rewardedAd?.load()
		}
    }

	func showInterstitialAd() async throws -> Bool {
		try await withCheckedThrowingContinuation { continuation in
			adClosed = continuation
			interstitialAd?.show()
		}
	}

	func showRewardedAd() async throws -> AbstractReward? {
		try await withCheckedThrowingContinuation { continuation in
			rewardedAdClosed = continuation
			rewardedAd?.show()
		}
	}
	
    func showMediationDebugger() {
        sdk?.showMediationDebugger()
    }

    private let key: KovaleeKeys.Applovin
    private let sdk: ALSdk?
    private var configuration: ALSdkConfiguration?
    private var interstitialAd: MAInterstitialAd?
    private var rewardedAd: MARewardedAd?
    private var retryAttempt = 0.0

	private var interstitialUnitId: String
	private var rewardedUnitId: String
	
	private var interstitialAdReady: CheckedContinuation<Bool, Error>?
	private var rewardedAdReady: CheckedContinuation<Bool, Error>?
	private var adClosed: CheckedContinuation<Bool, Error>?
	private var rewardedAdClosed: CheckedContinuation<AbstractReward, Error>?
}

// swiftlint:disable identifier_name
extension ApplovinWrapperImpl: MAAdDelegate, MARewardedAdDelegate {
    func didLoad(_ ad: AppLovinSDK.MAAd) {
        // Reset retry attempt
        retryAttempt = 0

		if ad.adUnitIdentifier == interstitialUnitId {
			KLogger.debug("📺 Interstitial Ad ready to be shown")
			interstitialAdReady?.resume(returning: true)
			interstitialAdReady = nil
		}
		if ad.adUnitIdentifier == rewardedUnitId {
			KLogger.debug("📺 Rewarded Ad ready to be shown")
			rewardedAdReady?.resume(returning: true)
			rewardedAdReady = nil
		}
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        // ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
		KLogger.error("📺 Failed to load ad with unitId: \(adUnitIdentifier)")

        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) { [weak self] in
			if adUnitIdentifier == self?.interstitialUnitId {
				self?.interstitialAd?.load()
			}

			if adUnitIdentifier == self?.rewardedUnitId {
				self?.rewardedAd?.load()
			}
        }
    }

    func didDisplay(_ ad: AppLovinSDK.MAAd) {}

	func didHide(_ ad: MAAd) {
		KLogger.debug("📺 Ad has been hidden")
		adClosed?.resume(returning: true)
		adClosed = nil
    }

    func didClick(_ ad: AppLovinSDK.MAAd) {}

    func didFail(toDisplay ad: AppLovinSDK.MAAd, withError error: MAError) {
		KLogger.debug("📺 Failed to display ads")
    }

    func didRewardUser(for ad: AppLovinSDK.MAAd, with reward: MAReward) {
		rewardedAdClosed?.resume(returning: Reward.map(from: reward))
		KLogger.debug("📺 Rewarded ad has been seen. Reward: \(reward.label) \(reward.amount)")
		rewardedAdClosed = nil
    }
}
// swiftlint:enable identifier_name

extension LogLevel {
    func applovinLogLevel() -> Bool {
        switch self {
        case .info, .verbose, .debug, .warn:
            return true
        default:
            return false
        }
    }
}

public struct Reward: AbstractReward {
	public var label: String
	public var amount: Int
}

extension Reward {
	static func map(from aReward: MAReward) -> Self {
		Reward(
			label: aReward.label,
			amount: aReward.amount
		)
	}
}
