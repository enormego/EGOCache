//
//  EGOCache.h
//  enormego
//
//  Created by Shaun Harrison.
//  Copyright (c) 2009-2015 enormego.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#if !__has_feature(nullability)
#	define nullable
#	define nonnull
#	define __nullable
#	define __nonnull
#endif

@interface EGOCache : NSObject

+ (nonnull instancetype)currentCache __deprecated_msg("Renamed to globalCache");

// Global cache for easy use
+ (nonnull instancetype)globalCache;

// Opitionally create a different EGOCache instance with it's own cache directory
- (nonnull instancetype)initWithCacheDirectory:(NSString* __nonnull)cacheDirectory;

- (void)clearCache;
- (void)removeCacheForKey:(NSString* __nonnull)key;

- (BOOL)hasCacheForKey:(NSString* __nonnull)key;

- (NSData* __nullable)dataForKey:(NSString* __nonnull)key;
- (void)setData:(NSData* __nonnull)data forKey:(NSString* __nonnull)key;
- (void)setData:(NSData* __nonnull)data forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSString* __nullable)stringForKey:(NSString* __nonnull)key;
- (void)setString:(NSString* __nonnull)aString forKey:(NSString* __nonnull)key;
- (void)setString:(NSString* __nonnull)aString forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSDate* __nullable)dateForKey:(NSString* __nonnull)key;
- (NSArray* __nonnull)allKeys;

#if TARGET_OS_IPHONE
- (UIImage* __nullable)imageForKey:(NSString* __nonnull)key;
- (void)setImage:(UIImage* __nonnull)anImage forKey:(NSString* __nonnull)key;
- (void)setImage:(UIImage* __nonnull)anImage forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#else
- (NSImage* __nullable)imageForKey:(NSString* __nonnull)key;
- (void)setImage:(NSImage* __nonnull)anImage forKey:(NSString* __nonnull)key;
- (void)setImage:(NSImage* __nonnull)anImage forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#endif

- (NSData* __nullable)plistForKey:(NSString* __nonnull)key;
- (void)setPlist:(nonnull id)plistObject forKey:(NSString* __nonnull)key;
- (void)setPlist:(nonnull id)plistObject forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)copyFilePath:(NSString* __nonnull)filePath asKey:(NSString* __nonnull)key;
- (void)copyFilePath:(NSString* __nonnull)filePath asKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (nullable id<NSCoding>)objectForKey:(NSString* __nonnull)key;
- (void)setObject:(nonnull id<NSCoding>)anObject forKey:(NSString* __nonnull)key;
- (void)setObject:(nonnull id<NSCoding>)anObject forKey:(NSString* __nonnull)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

@property(nonatomic) NSTimeInterval defaultTimeoutInterval; // Default is 1 day
@end