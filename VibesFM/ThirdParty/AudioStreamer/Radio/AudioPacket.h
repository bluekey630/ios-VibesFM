//
//  AudioPacket.h
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
#import <AudioToolbox/AudioToolbox.h>

@interface AudioPacket : NSObject

@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) AudioStreamPacketDescription audioDescription;

- (id)initWithData:(NSData *)data;

- (NSUInteger)length;
- (NSUInteger)remainingLength;
- (void)copyToBuffer:(void *const)buffer size:(int)size;

@end
