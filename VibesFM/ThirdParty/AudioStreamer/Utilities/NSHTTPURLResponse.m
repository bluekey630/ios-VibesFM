//
//  NSHTTPURLResponse.m
//  Radio 7 Pro
//
//  Created by Christopher Coudriet on 10/15/2012.
//  Copyright Christopher Coudriet 2012. All rights reserved.
//
//  Permission is given to license this source code file, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that this source code cannot be redistributed or sold (in part or whole) and must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "NSHTTPURLResponse.h"

static Boolean CaseInsensitiveEqual(const void *a, const void *b) {
    return ([(__bridge id)a compare:(__bridge id)b options:NSCaseInsensitiveSearch | NSLiteralSearch] == NSOrderedSame);
}

static CFHashCode CaseInsensitiveHash(const void *value) {
    return [[(__bridge id)value lowercaseString] hash];
}

@implementation NSHTTPURLResponse (NSHTTPURLResponse)

- (NSDictionary *)caseInsensitiveHTTPHeaders {
    NSDictionary *src = [self allHeaderFields];
    
    CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
    keyCallbacks.equal = CaseInsensitiveEqual;
    keyCallbacks.hash = CaseInsensitiveHash;
    
    CFMutableDictionaryRef dest = CFDictionaryCreateMutable(kCFAllocatorDefault, 
                                                            [src count], 
                                                            &keyCallbacks, 
                                                            &kCFTypeDictionaryValueCallBacks);

    NSEnumerator *enumerator = [src keyEnumerator];
    id key = nil;
    while((key = [enumerator nextObject])) {
        id value = [src objectForKey:key];
        [(__bridge NSMutableDictionary *)dest setObject:value forKey:key];
    }
     
    return [(__bridge NSDictionary *)dest autorelease];
}

@end
