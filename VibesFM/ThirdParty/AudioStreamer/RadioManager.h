//
//  RadioManager.h
//  Radio
//
//  Created by Admin on 21/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import <UIKit/UIKit.h>
#import "Radio.h"

@protocol RadioManagerDelegate;

@interface RadioManager : NSObject <RadioDelegate, NSURLConnectionDataDelegate>
{
}

-(id) init;

@property (nonatomic, weak) id<RadioManagerDelegate> delegate;

@property (nonatomic, strong)   Radio *radio;

@property (nonatomic, strong)   NSString *metadataArtist;
@property (nonatomic, strong)   NSString *metadataTitle;
@property (nonatomic, strong)   NSString *metadataAlbum;

@property (nonatomic, retain) NSMutableData                    *responseData;
@property (nonatomic, retain) NSURLConnection                  *connection;

- (void)createStreamer:(NSString *) strLink;
- (void) playRadio;
- (void) stopCurrentPlayer;

@end

@protocol RadioManagerDelegate <NSObject>

@optional
- (void) beginInterruption;
- (void) endInterruption;
- (void) refreshPlaying:(NSString *) strState;
- (void) radioStateChanged:(RadioState) radioState;
- (void) radioMetadataReady:(NSString *) strMetaData;
- (void) radioInfoWithTitle:(NSString *) strTitle withArtist:(NSString *) strArtist;

@end
