Pod::Spec.new do |s|
  s.name         = "EGOCache"
  s.version      = "2.1"
  s.summary      = "Fast Caching for Objective-C (iPhone & Mac Compatible)."
  s.description  = "EGOCache is a simple, thread-safe key value cache store. It has native support for NSString, UI/NSImage, and NSData, but can store anything that implements <NSCoding>. All cached items expire after the timeout, which by default, is one day."
  s.homepage     = "https://github.com/enormego/EGOCache"
  s.license      = "MIT"
  s.author       = "Enormego, Shaun Harrison"
  s.source       = { :git => "https://github.com/enormego/EGOCache.git", :tag => "v" + s.version.to_s }
  s.requires_arc = true
  s.source_files = "*.{h,m}"
end