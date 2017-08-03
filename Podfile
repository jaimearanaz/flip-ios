source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

# ignore all warnings from all pods
inhibit_all_warnings!

# XCode warns about fake errors when using CocoaPods views in Interface Builder
# to solve it, use frameworks instead static libraries
use_frameworks!

def flip_pods
    
    #pod 'Facebook-iOS-SDK'
    pod 'PFTwitterSignOn', :git => 'https://github.com/jesseditson/PFTwitterSignOn.git'
    pod 'STTwitter'
	pod 'SCNetworkReachability'
    pod 'RZSquaresLoading'
    pod 'SDCAlertView', :git => 'https://github.com/sberrevoets/SDCAlertView'
    pod 'UINavigationControllerWithCompletionBlock'
    pod 'SDWebImage'
end

target 'Flip' do
    flip_pods
end

target 'FlipTests' do
    flip_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
