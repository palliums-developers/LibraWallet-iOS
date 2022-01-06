# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'
 inhibit_all_warnings!

target 'LibraWallet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
#  pod 'CryptoSwift'
#  pod 'SwiftProtobuf'
#  pod 'BigInt'
#  pod 'SwiftGRPC'
#  pod 'SnapKit'
#  pod 'Toast-Swift'
#  pod 'Hue'
#  pod 'SQLite.swift'
#  pod 'Localize-Swift'
#  pod 'Alamofire'
#  pod 'Moya'
#  pod 'MJRefresh'
#  pod 'KeychainAccess'
  pod 'StatefulViewController'
#  pod 'IQKeyboardManagerSwift'
#  pod 'BiometricAuthentication'
#  pod 'RSKPlaceholderTextView'
  pod 'BitcoinKit', :git => 'https://github.com/dongdongpc/BitcoinKit.git'
#  pod 'Kingfisher'
  pod 'AttributedTextView'
#  pod 'Socket.IO-Client-Swift'
  pod 'Device'
#  pod 'JXSegmentedView'
#  pod 'WalletConnectSwift'
#  pod 'Firebase/Messaging'
  pod "DropDownMenuKit"
#  pod 'WKWebViewJavascriptBridge'
  # Pods for LibraWallet

  target 'LibraWalletTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LibraWalletUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
    end
end
