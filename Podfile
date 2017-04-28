# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VibesFM' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VibesFM
  pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :tag => '3.5.0'
  pod "SwiftyJSON", :git => "https://github.com/SwiftyJSON/SwiftyJSON", :branch => "swift2"
  pod "MarqueeLabel", :git => "https://github.com/cbpowell/MarqueeLabel", :branch => "swift-2.3"
  pod 'GoogleMobileAds'
  pod 'Kanna', '~> 1.1.0'
  pod 'Harpy' 
  pod 'Google/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "2.3"
    end
  end
end
