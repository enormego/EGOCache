# EGOCache
EGOCache is a simple, thread-safe key value cache store for macOS, iOS, tvOS and watchOS.

It has native support for `NSString`, `UIImage`, `NSImage`, and `NSData`, but can store anything that implements `<NSCoding>`.  All cached items expire after the timeout, which by default, is one day.

## Installation

### Carthage

```
github "enormego/EGOCache" ~> 2.2.0
```

### CocoaPods

```
pod 'EGOCache', '~> 2.2.0'
```

### Without a dependency manager

Drag EGOCache.h and EGOCache.m into your project.

## License
Copyright (c) 2017 enormego

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

