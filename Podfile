# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'

target 'Happy' do

pod 'SWRevealViewController'
pod 'TSMarkdownParser'
pod 'HockeySDK'
pod 'ARAnalytics', :subspecs => ["Mixpanel", "GoogleAnalytics"]

end

target 'HappyTests' do

end

target 'HappyUITests' do

end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Happy/Pods-Happy-acknowledgements.plist', 'Happy/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end


