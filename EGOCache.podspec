Pod::Spec.new do |s|
  s.name            = 'EGOCache'
  s.version         = '2.0'
  s.license         = 'MIT'
  s.summary         = 'Fast Caching for Objective-C (iPhone & Mac Compatible)'
  s.homepage        = 'https://github.com/enormego/EGOCache'
  s.source          = {:git => 'https://github.com/enormego/EGOCache.git', :tag => 'v2.0'}
  
  s.platforms       = 'iOS', 'OSX'
  
  s.source_files    = '*.{h,m}'
  s.requires_arc    = true
  
  s.ios.frameworks  = 'Foundation', 'UIKit'
end