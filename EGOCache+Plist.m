#import "EGOCache.h"
#import "EGOCache+Plist.h"

@implementation EGOCache (Plist)

- (NSData*)plistForKey:(NSString*)key;
{  
  NSData *plistData = [self dataForKey:key];
  return [NSPropertyListSerialization 
    propertyListFromData:plistData 
        mutabilityOption:NSPropertyListImmutable 
                  format:nil 
        errorDescription:nil];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key;
{
  [self setPlist:plistObject forKey:key withTimeoutInterval:60 * 60 * 24];
}

// XML format would produce cache files that are human-readable but at the
// expense of performance, so I felt binary format was best.

- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
{
  NSString *errorString;
  NSData *plistData = [NSPropertyListSerialization 
    dataFromPropertyList:plistObject 
                  format:NSPropertyListBinaryFormat_v1_0 
        errorDescription:&errorString];
  
  [self setData:plistData forKey:key withTimeoutInterval:timeoutInterval];
}

@end
