//
//  EGOCache.m
//  enormego
//
//  Created by Shaun Harrison on 7/4/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import "EGOCache.h"

#define cachePathForKey(key) [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/EGOCache/%@", key]]

static id __instance;

@implementation EGOCache

+ (EGOCache*)currentCache {
	@synchronized(self) {
		if(!__instance) {
			__instance = [[EGOCache alloc] init];
		}
	}
	
	return __instance;
}

- (id)init {
	if((self = [super init])) {
		NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"EGOCache"];
		if([dict isKindOfClass:[NSDictionary class]]) {
			cacheDictionary = [dict mutableCopy];
		} else {
			cacheDictionary = [[NSMutableDictionary alloc] init];
		}
		
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePathForKey(@"") 
								  withIntermediateDirectories:YES 
												   attributes:nil 
														error:NULL];
		
		for(NSString* key in cacheDictionary) {
			NSDate* date = [cacheDictionary objectForKey:key];
			if([date isPastDate]) {
				[[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(key) error:NULL];
			}
		}
	}
	
	return self;
}

#pragma mark -
#pragma mark Data methods

- (void)setData:(NSData*)data forKey:(NSString*)key {
	[self setData:data forKey:key withTimeoutInterval:60 * 60 * 24];
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[data writeToFile:cachePathForKey(key) atomically:YES];
	[cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval] forKey:key];
	[[NSUserDefaults standardUserDefaults] setObject:cacheDictionary forKey:@"EGOCache"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSData*)dataForKey:(NSString*)key {
	NSDate* date = [cacheDictionary objectForKey:key];
	if([date isPastDate]) {
		return nil;
	} else if([[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(key)]) {
		return [NSData dataWithContentsOfFile:cachePathForKey(key) options:0 error:NULL];
	} else {
		return nil;
	}
}

#pragma mark -
#pragma mark String methods

- (NSString*)stringForKey:(NSString*)key {
	return [[[NSString alloc] initWithData:[self dataForKey:key] encoding:NSUTF8StringEncoding] autorelease];
}

- (void)setString:(NSString*)aString forKey:(NSString*)key {
	[self setString:aString forKey:key withTimeoutInterval:60 * 60 * 24];
}

- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:[aString dataUsingEncoding:NSUTF8StringEncoding] forKey:key withTimeoutInterval:timeoutInterval];
}

#pragma mark -

- (void)dealloc {
	[cacheDictionary release];
	[super dealloc];
}

@end
