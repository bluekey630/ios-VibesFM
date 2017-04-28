//
//  PLSParser.m
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

#import "PLSParser.h"

@implementation PLSParser

- (id)init {
    self = [super init];
    if(self) {
        
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (NSString *)parseStreamUrl:(NSData *)httpData {
    NSString *document = [[[NSString alloc] initWithBytes:[httpData bytes] length:[httpData length] encoding:NSUTF8StringEncoding] autorelease];
    if(document == nil) {
        document = [[[NSString alloc] initWithBytes:[httpData bytes] length:[httpData length] encoding:NSASCIIStringEncoding] autorelease];
    }
    NSArray *lines = [document componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if(lines && [lines count] > 0) {
        for(NSString *line in lines) {
            if([line hasPrefix:@"File"]) {
                NSRange r = [line rangeOfString:@"="];
                if(r.location != NSNotFound) {
                    NSString *streamUrl = [line substringFromIndex:(r.location+1)];
                    return streamUrl;
                }
            }
        }
    }
    
    return nil;
}

@end
