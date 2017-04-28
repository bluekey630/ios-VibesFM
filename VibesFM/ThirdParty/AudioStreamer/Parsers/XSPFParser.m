//
//  XSPFParser.m
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

#import "XSPFParser.h"
#import "XMLUtilities.h"

@implementation XSPFParser

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
    NSDictionary *nsMappings = [NSDictionary dictionaryWithObjectsAndKeys:@"http://xspf.org/ns/0/", @"xspf", nil];
    NSArray *tracks = PerformXMLXPathQuery(httpData, nsMappings, @"//xspf:track/xspf:location");
    if(tracks && [tracks count] > 0) {
        NSDictionary *track = [tracks objectAtIndex:0];
        if(track) {
            NSString *streamUrl = [track objectForKey:@"nodeContent"];
            return streamUrl;
        }
    }
    
    return nil;
}

@end
