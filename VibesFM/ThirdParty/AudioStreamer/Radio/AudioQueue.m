//
//  AudioQueue.m
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

#import "AudioQueue.h"
#import "AudioPacket.h"

@interface AudioQueue () {
    NSMutableArray *_audioPackets;
}

@end

@implementation AudioQueue

- (id)init {
    self = [super init];
    if(self) {
        _audioPackets = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_audioPackets release];
    [super dealloc];
}

- (AudioPacket *)pop {
    AudioPacket *packet = nil;
    packet = [_audioPackets lastObject];
    if(packet) {
        [packet retain];
        [_audioPackets removeLastObject];
    }
    
    return packet;
}

- (AudioPacket *)peak {
    return [_audioPackets lastObject];
}

- (void)addPacket:(AudioPacket *)packet {
    [_audioPackets insertObject:packet atIndex:0];
}

- (void)removeAllPackets {
    [_audioPackets removeAllObjects];
}

- (NSUInteger)count {
    return [_audioPackets count];
}

@end
