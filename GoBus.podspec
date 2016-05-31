Pod::Spec.new do |s|
  s.name             = 'GoBus'
  s.version          = '0.1.2'
  s.summary          = 'Elegant way to get data from Inthegra API.'
  s.homepage         = 'https://github.com/orlandoamorim/GoBus'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Orlando Amorim' => 'orlandoamorimdev@gmail.com' }
  s.source           = { :git => 'https://github.com/orlandoamorim/GoBus.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/or_amorim'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.ios.deployment_target = '8.0'
  s.source_files = 'GoBus/Classes/**/*.swift'

end
