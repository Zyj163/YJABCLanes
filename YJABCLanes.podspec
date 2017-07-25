#
# Be sure to run `pod lib lint YJABCLanes.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YJABCLanes'
  s.version          = '0.1.0'
  s.summary          = '弹幕视图'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
简单的弹幕视图
                       DESC

  s.homepage         = 'https://github.com/Zyj163/YJABCLanes'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zyj163' => 'zyj194250@163.com' }
  s.source           = { :git => 'https://github.com/Zyj163/YJABCLanes.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'YJABCLanes/Classes/**/*'
  s.frameworks = 'UIKit'
end
