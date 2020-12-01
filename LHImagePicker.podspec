Pod::Spec.new do |s|
  s.name = "LHImagePicker"
  s.version = "1.0"
  s.summary = "Image picker with custom crop rect for iOS written in Swift"
  s.description = "LHImagePicker"
  s.homepage = "https://github.com/laohac8x/LHImagePicker"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Dat Ng" => "laohac83x@gmail.com" }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.source = { :git => 'https://github.com/laohac8x/LHImagePicker.git', :tag => '1.0' }
  s.source_files = "Classes/*.swift"
end