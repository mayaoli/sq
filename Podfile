platform :ios, '11.0'

use_frameworks!

inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'

project 'Employees.xcodeproj'

def public_pods
  pod 'SwiftyJSON', '3.1.4'
  pod 'Alamofire', '4.4.0'
  pod 'SWXMLHash', '4.2.1'
  pod 'SDWebImage', '~> 3.8.1'
  pod 'Shimmer', '1.0.2'
  pod 'TTGSnackbar', '~> 1.7.5'
  pod 'ProgressHUD', '~> 2.60'
  
  pod 'SwiftLint', '0.23.1'
end
  
target 'Employees' do
  public_pods
end

target 'EmployeesTests' do
  public_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # turn on bitcode to keep our app size smaller
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      config.build_settings['SWIFT_VERSION'] = '4.2'
      
#      if target.name == "TTGSnackbar"
#        config.build_settings['SWIFT_VERSION'] = '4.0'
#      else
#        config.build_settings['SWIFT_VERSION'] = '4.2'
#      end
#
#      # remove strict prototypes warning
#      # this seems to be a particularly chatty warning, that affects many of our dependencies
#      # and even apple isn't doing this correctly everywhere
#      # in order to make our actual warning count more meaningful, removing them for now
#      # https://stackoverflow.com/questions/44473146/this-function-declaration-is-not-a-prototype-warning-in-xcode-9
      config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'NO'
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
