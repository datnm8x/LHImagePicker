# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

target 'LHImagePicker' do
  # Comment the next line if you don't want to use dynamic frameworks
  pod 'SwiftFormat/CLI'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
#      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
