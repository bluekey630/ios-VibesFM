//
//  AudioPacket.m
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

#import "AudioPacket.h"

@interface AudioPacket () {
    NSData *_data;
    AudioStreamPacketDescription _audioDescription;
    
    NSUInteger _consumedLength;
}

@end

@implementation AudioPacket

@synthesize data = _data;
@synthesize audioDescription = _audioDescription;

- (id)initWithData:(NSData *)data {
    self = [super init];
    if(self) {
        _data = [data retain];
        _consumedLength = 0;
    }
    
    return self;
}

- (void)dealloc {
    [_data release];
    
    [super dealloc];
}

- (NSUInteger)length {
    return [_data length];
}

- (NSUInteger)remainingLength {
    return ([_data length] - _consumedLength);
}

- (void)copyToBuffer:(void *const)buffer size:(int)size {
    int dataSize = size;
    if((_consumedLength + dataSize) > [self length]) {
        dataSize = [self length] - _consumedLength;
    }
    
    memcpy(buffer, ([_data bytes] + _consumedLength), dataSize);
    _consumedLength += dataSize;
}

@end
