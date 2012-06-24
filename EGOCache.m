//
//  EGOCache.m
//  enormego
//
//  Created by Shaun Harrison on 7/4/09.
//  Copyright (c) 2009-2010 enormego
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

#import "EGOCache.h"

#if DEBUG
#define CHECK_FOR_EGOCACHE_PLIST() if([key isEqualToString:@"EGOCache.plist"]) { \
NSLog(@"EGOCache.plist is a reserved key and can not be modified."); \
return; }
#else
#define CHECK_FOR_EGOCACHE_PLIST() if([key isEqualToString:@"EGOCache.plist"]) return;
#endif

#ifdef __has_feature
#define EGO_NO_ARC !__has_feature(objc_arc)
#else
#define EGO_NO_ARC 1
#endif

static NSString* _EGOCacheDirectory;

static inline NSString* EGOCacheDirectory() {
	if(!_EGOCacheDirectory) {
		NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		_EGOCacheDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"EGOCache"] copy];
	}
	
	return _EGOCacheDirectory;
}

static inline NSString* cachePathForKey(NSString* key) {
	return [EGOCacheDirectory() stringByAppendingPathComponent:key];
}

static EGOCache* __instance;

@interface EGOCache ()
- (void)removeItemFromCache:(NSString*)key;
- (void)performDiskWriteOperation:(NSInvocation *)invocation;
- (void)saveCacheDictionary;
@end

#pragma mark -

@implementation EGOCache
@synthesize defaultTimeoutInterval;

+ (EGOCache*)currentCache {
	@synchronized(self) {
		if(!__instance) {
			__instance = [[EGOCache alloc] init];
			__instance.defaultTimeoutInterval = 86400;
		}
	}
	
	return __instance;
}

- (id)init {
	if((self = [super init])) {
		NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:cachePathForKey(@"EGOCache.plist")];
		
		if([dict isKindOfClass:[NSDictionary class]]) {
			cacheDictionary = [dict mutableCopy];
		} else {
			cacheDictionary = [[NSMutableDictionary alloc] init];
		}
		
		diskOperationQueue = [[NSOperationQueue alloc] init];
		
		[[NSFileManager defaultManager] createDirectoryAtPath:EGOCacheDirectory() 
                              withIntermediateDirectories:YES 
                                               attributes:nil 
                                                    error:NULL];
		
		NSMutableArray *removeList = [NSMutableArray array];
		for(NSString* key in cacheDictionary) {
			NSDate* date = [cacheDictionary objectForKey:key];
			if([[[NSDate date] earlierDate:date] isEqualToDate:date]) {
				[removeList addObject:key];
				[[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(key) error:NULL];
			}
		}
		if ([removeList count] > 0) {
			[cacheDictionary removeObjectsForKeys:removeList];
		}
	}
	
	return self;
}

- (void)clearCache {
	for(NSString* key in [cacheDictionary allKeys]) {
		[self removeItemFromCache:key];
	}
	
	[self saveCacheDictionary];
}

- (void)removeCacheForKey:(NSString*)key {
	CHECK_FOR_EGOCACHE_PLIST();
  
	[self removeItemFromCache:key];
	[self saveCacheDictionary];
}

- (void)removeItemFromCache:(NSString*)key {
	NSString* cachePath = cachePathForKey(key);
	
	NSInvocation* deleteInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(deleteDataAtPath:)]];
	[deleteInvocation setTarget:self];
	[deleteInvocation setSelector:@selector(deleteDataAtPath:)];
	[deleteInvocation setArgument:&cachePath atIndex:2];
	
	[self performDiskWriteOperation:deleteInvocation];
	[cacheDictionary removeObjectForKey:key];
}

- (BOOL)hasCacheForKey:(NSString*)key {
	NSDate* date = [cacheDictionary objectForKey:key];
	if(!date) return NO;
	if([[[NSDate date] earlierDate:date] isEqualToDate:date]) return NO;
	return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(key)];
}

#pragma mark -
#pragma mark Copy file methods

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key {
	[self copyFilePath:filePath asKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:cachePathForKey(key) error:NULL];
	[cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval] forKey:key];
	[self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES];
}																												   

#pragma mark -
#pragma mark Data methods

- (void)setData:(NSData*)data forKey:(NSString*)key {
	[self setData:data forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	CHECK_FOR_EGOCACHE_PLIST();
	
	NSString* cachePath = cachePathForKey(key);
	NSInvocation* writeInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(writeData:toPath:)]];
	[writeInvocation setTarget:self];
	[writeInvocation setSelector:@selector(writeData:toPath:)];
	[writeInvocation setArgument:&data atIndex:2];
	[writeInvocation setArgument:&cachePath atIndex:3];
	
	[self performDiskWriteOperation:writeInvocation];
	[cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval] forKey:key];
	
	[self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES]; // Need to make sure the save delay get scheduled in the main runloop, not the current threads
}

- (void)saveAfterDelay { // Prevents multiple-rapid saves from happening, which will slow down your app
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveCacheDictionary) object:nil];
	[self performSelector:@selector(saveCacheDictionary) withObject:nil afterDelay:0.3];
}

- (NSData*)dataForKey:(NSString*)key {
	if([self hasCacheForKey:key]) {
		return [NSData dataWithContentsOfFile:cachePathForKey(key) options:0 error:NULL];
	} else {
		return nil;
	}
}

- (void)writeData:(NSData*)data toPath:(NSString *)path; {
	[data writeToFile:path atomically:YES];
} 

- (void)deleteDataAtPath:(NSString *)path {
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)saveCacheDictionary {
	@synchronized(self) {
		[cacheDictionary writeToFile:cachePathForKey(@"EGOCache.plist") atomically:YES];
	}
}

#pragma mark -
#pragma mark String methods

- (NSString*)stringForKey:(NSString*)key {
  NSString *string = [[NSString alloc] initWithData:[self dataForKey:key] encoding:NSUTF8StringEncoding];
#if EGO_NO_ARC
  return [string autorelease];
#endif
  return string;
}

- (void)setString:(NSString*)aString forKey:(NSString*)key {
	[self setString:aString forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:[aString dataUsingEncoding:NSUTF8StringEncoding] forKey:key withTimeoutInterval:timeoutInterval];
}

#pragma mark -
#pragma mark Image methds

#if TARGET_OS_IPHONE

- (UIImage*)imageForKey:(NSString*)key {
	return [UIImage imageWithContentsOfFile:cachePathForKey(key)];
}

- (void)setImage:(UIImage*)anImage forKey:(NSString*)key {
	[self setImage:anImage forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:UIImagePNGRepresentation(anImage) forKey:key withTimeoutInterval:timeoutInterval];
}


#else

- (NSImage*)imageForKey:(NSString*)key {
	return [[[NSImage alloc] initWithData:[self dataForKey:key]] autorelease];
}

- (void)setImage:(NSImage*)anImage forKey:(NSString*)key {
	[self setImage:anImage forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setImage:(NSImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:[[[anImage representations] objectAtIndex:0] representationUsingType:NSPNGFileType properties:nil]
         forKey:key withTimeoutInterval:timeoutInterval];
}

#endif

#pragma mark -
#pragma mark Property List methods

- (NSData*)plistForKey:(NSString*)key; {  
	NSData* plistData = [self dataForKey:key];
	
	return [NSPropertyListSerialization propertyListFromData:plistData
                                          mutabilityOption:NSPropertyListImmutable
                                                    format:nil
                                          errorDescription:nil];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key; {
	[self setPlist:plistObject forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval; {
	// Binary plists are used over XML for better performance
	NSData* plistData = [NSPropertyListSerialization dataFromPropertyList:plistObject 
                                                                 format:NSPropertyListBinaryFormat_v1_0
                                                       errorDescription:NULL];
	
	[self setData:plistData forKey:key withTimeoutInterval:timeoutInterval];
}

#pragma mark -
#pragma mark Object methods

- (id<NSCoding>)objectForKey:(NSString*)key {
	if([self hasCacheForKey:key]) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForKey:key]];
	} else {
		return nil;
	}
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key {
	[self setObject:anObject forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setObject:(id<NSCoding>)anObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:[NSKeyedArchiver archivedDataWithRootObject:anObject] forKey:key withTimeoutInterval:timeoutInterval];
}

#pragma mark -
#pragma mark Disk writing operations

- (void)performDiskWriteOperation:(NSInvocation *)invocation {
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
	[diskOperationQueue addOperation:operation];
#if EGO_NO_ARC
	[operation release];
#endif
}

#pragma mark -

- (void)dealloc {
#if EGO_NO_ARC
	[diskOperationQueue release];
	[cacheDictionary release];
	[super dealloc];
#endif
}

@end