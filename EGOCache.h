//
//  EGOCache.h
//  enormego
//
//  Created by Shaun Harrison on 7/4/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EGOCache : NSObject {
@private
	NSMutableDictionary* cacheDictionary;
}

+ (EGOCache*)currentCache;

- (BOOL)hasCacheForKey:(NSString*)key;

- (NSData*)dataForKey:(NSString*)key;
- (void)setData:(NSData*)data forKey:(NSString*)key; // withTimeoutInterval: 1 day
- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSString*)stringForKey:(NSString*)key;
- (void)setString:(NSString*)aString forKey:(NSString*)key; // withTimeoutInterval: 1 day
- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

#if TARGET_OS_IPHONE
- (UIImage*)imageForKey:(NSString*)key;
- (void)setImage:(UIImage*)anImage forKey:(NSString*)key; // withTimeoutInterval: 1 day
- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#else
- (NSImage*)imageForKey:(NSString*)key;
- (void)setImage:(NSImage*)anImage forKey:(NSString*)key; // withTimeoutInterval: 1 day
- (void)setImage:(NSImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#endif

@end
