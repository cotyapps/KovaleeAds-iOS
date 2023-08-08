#
#  Be sure to run `pod spec lint KovaleeAds.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "KovaleeAds"
  spec.version      = "1.0.2"
  spec.summary      = "KovaleeAds simplifies displaying ads in app."
  spec.description  = <<-DESC
  If you're not on the subscription train, you can still monetize your app with ads. KovaleeAds provides an intuitive interface for adding both interstitial and rewarded ads within your app. 
  It's part of a broader project KovaleeSDK
                   DESC
                
  spec.license      = { :type => 'MIT', :file => 'MIT-LICENSE' }
  spec.homepage     = "https://github.com/cotyapps/KovaleeAds-iOS"
  spec.author       = { "fto-k" => "fto@kovalee.app" }

  spec.source       = { :git => "https://github.com/cotyapps/KovaleeAds-iOS.git", :tag => "#{spec.version}" }

  spec.ios.deployment_target = '14.3'
  spec.swift_version    = '5.7'
  spec.source_files  = "Sources/KovaleeAds/*.swift"

  spec.static_framework = true

  spec.dependency "KovaleeSDK"
  spec.dependency "AppLovinSDK"
  spec.dependency "AppLovinMediationAdColonyAdapter"
  spec.dependency "AppLovinMediationGoogleAdapter"
  spec.dependency "AppLovinMediationIronSourceAdapter"
  spec.dependency "AppLovinMediationFacebookAdapter"
  spec.dependency "AppLovinMediationUnityAdsAdapter"

end