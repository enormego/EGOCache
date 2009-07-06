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

- (NSData*)dataForKey:(NSString*)key;
- (void)setData:(NSData*)data forKey:(NSString*)key; // withTimeoutInterval: 1 day
- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSString*)stringForKey:(NSString*)key;
- (void)setString:(NSString*)aString forKey:(NSString*)key; // withTimeoutInterval: 1 day
- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

@end
