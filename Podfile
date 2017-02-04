source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

# ignore all warnings from all pods
inhibit_all_warnings!

# XCode warns about fake errors when using CocoaPods views in Interface Builder
# to solve it, use frameworks instead static libraries
use_frameworks!

def flip_pods
	pod 'CocoaLumberjack', '~> 1.6.2'
	pod 'MBProgressHUD', '~> 0.8'
	pod 'WCAlertView', '~> 1.0.1'
	pod 'PFTwitterSignOn', :git => 'https://github.com/jesseditson/PFTwitterSignOn.git'
	pod 'STTwitter', '~> 0.1.4'
	pod 'SCNetworkReachability'
	pod 'Facebook-iOS-SDK', '~> 3.12.0'
end

target 'Flip' do
    flip_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end