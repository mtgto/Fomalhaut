workspace 'Fomalhaut'
xcodeproj 'FomalhautIOS/FomalhautIOS.xcodeproj'
xcodeproj 'FomalhautOSX/FomalhautOSX.xcodeproj'

pod 'MagicalRecord', '~> 2.2'
pod 'CocoaLumberjack', '~> 1.7.0'

target 'FomalhautIOS', :exclusive => false do
  platform :ios, '6.0'
  xcodeproj 'FomalhautIOS/FomalhautIOS.xcodeproj'
  pod 'AFNetworking', '~> 2.0.3'
end

target 'FomalhautOSX', :exclusive => false do
  platform :osx, '10.7'
  xcodeproj 'FomalhautOSX/FomalhautOSX.xcodeproj'
  pod 'zipzap', '~> 5.0'
  pod 'RoutingHTTPServer', '~> 1.0.0'
  pod 'GRMustache', '~> 6.8.3'
end

