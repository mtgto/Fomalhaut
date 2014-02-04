workspace 'Fomalhaut'
xcodeproj 'FomalhautIOS/FomalhautIOS.xcodeproj'
xcodeproj 'FomalhautOSX/FomalhautOSX.xcodeproj'

target 'FomalhautIOS', :exclusive => false do
  platform :ios, '6.0'
  xcodeproj 'FomalhautIOS/FomalhautIOS.xcodeproj'
  pod 'CocoaLumberjack', '~> 1.7.0'
  pod 'AFNetworking', '~> 2.1.0'
  pod 'CXPhotoBrowser', '~> 1.1.1'
end

target 'FomalhautOSX', :exclusive => false do
  platform :osx, '10.7'
  xcodeproj 'FomalhautOSX/FomalhautOSX.xcodeproj'
  pod 'MagicalRecord', '~> 2.2'
  pod 'CocoaLumberjack', '~> 1.7.0'
  pod 'zipzap', '~> 5.0'
  pod 'RoutingHTTPServer', '~> 1.0.0'
  pod 'GRMustache', '~> 6.8.3'
end

