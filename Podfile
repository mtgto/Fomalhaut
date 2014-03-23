workspace 'Fomalhaut'
xcodeproj 'FomalhautIOS/FomalhautIOS.xcodeproj'
xcodeproj 'FomalhautOSX/FomalhautOSX.xcodeproj'

target 'FomalhautIOS', :exclusive => false do
  platform :ios, '6.0'
  xcodeproj 'FomalhautIOS/FomalhautIOS.xcodeproj'
  pod 'CocoaLumberjack', '~> 1.8.1'
  pod 'AFNetworking', '~> 2.2.1'
  pod 'CXPhotoBrowser', '~> 1.1.1'
  pod 'SSKeychain', '~> 1.2.1'
end

target 'FomalhautOSX', :exclusive => false do
  platform :osx, '10.7'
  xcodeproj 'FomalhautOSX/FomalhautOSX.xcodeproj'
  pod 'MagicalRecord', '~> 2.2'
  pod 'CocoaLumberjack', '~> 1.8.1'
  pod 'zipzap', '~> 6.0'
  pod 'RoutingHTTPServer', '~> 1.0.0'
  pod 'GRMustache', '~> 6.9.2'
  pod 'SSKeychain', '~> 1.2.1'
end

