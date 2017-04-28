//
//  HTTPRadio.h
//  Radio
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

#import <Foundation/Foundation.h>
#import "Radio.h"
#import "PlaylistParser.h"

typedef enum {
    kPlaylistNone = 0,
    kPlaylistM3U,
    kPlaylistPLS,
    kPlaylistXSPF
} PlaylistType;

typedef enum {
    kHTTPStatePlaylistParsing = 0,
    kHTTPStateAudioStreaming
} HTTPState;

@interface Streamer : Radio

@property (nonatomic, copy) NSString *httpUserAgent;
@property (nonatomic, assign) NSUInteger httpTimeout;

@end
