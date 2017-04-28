//
//  RadioManager.m
//  Radio
//
//  Created by Admin on 21/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "RadioManager.h"
#import "Streamer.h"

// Last.FM API Key
#define LAST_FM_API_KEY @"Your Last.FM API Key"

#ifndef LAST_FM_API_KEY
#error "Must define Last.FM API key. Please visit http://www.last.fm/api to signup"
#endif

@implementation RadioManager

static void InterruptionListenerCallback(void *inUserData, UInt32 interruptionState)
{
    RadioManager *radioManager = (__bridge RadioManager *)inUserData;

    if(interruptionState == kAudioSessionBeginInterruption) {
        if (radioManager.delegate && [radioManager.delegate respondsToSelector:@selector(beginInterruption)])
            [radioManager.delegate beginInterruption];
    } else if(interruptionState == kAudioSessionEndInterruption) {
        AudioSessionSetActive(true);
        if (radioManager.delegate && [radioManager.delegate respondsToSelector:@selector(endInterruption)])
            [radioManager.delegate endInterruption];
    }
}

-(id) init
{
    if((self = [super init])) {
        _metadataAlbum = @"";
        _metadataTitle = @"";
        _metadataTitle = @"";
        
        AudioSessionInitialize(NULL, NULL, InterruptionListenerCallback, (__bridge void *)(self));
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshPlayer:)
                                                     name:@"refreshPlayer"
                                                   object:nil];
        
        // NowPlaying Support
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopPlayer:)
                                                     name:@"stopPlayer"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pausePlayer:)
                                                     name:@"pausePlayer"
                                                   object:nil];
    }
    
    return self;
}

- (void)createStreamer:(NSString *) strLink
{
    _radio = [[Streamer alloc] initWithURL:[NSURL URLWithString:strLink]];
    
    if(_radio) {
        [_radio setDelegate:self];
        [_radio play];
    }
}

- (void) playRadio {
    if([_radio isPlaying]) {
        
        [_radio pause];
    }
    else
    {
        [_radio play];
    }
}

// NowPlaying Support
- (void)stopPlayer:(NSNotification *)notification
{
    // NSLog(@"Stop Player");
    [self stopCurrentPlayer];
    
}

- (void) stopCurrentPlayer {
    if (_radio == nil) {
        return;
    }
    
    if(_radio) {
        
        _radio.delegate = nil;
        [_radio shutdown];
        _radio = nil;
    }
}

- (void)pausePlayer:(NSNotification *)notification
{
    // NSLog(@"Pause Player");
    
    if([_radio isPlaying]) {
        
        [_radio pause];
    }
    else
    {
        [_radio play];
    }
}
// End Now Playing Support

- (void)refreshPlayer:(NSNotification *)notification
{
    NSLog(@"refreshPlayer");
    
    NSUserDefaults *savedPlayerStatus = [NSUserDefaults standardUserDefaults];
    
    NSString *playing = [savedPlayerStatus stringForKey:@"Player"];
    
    if ([playing isEqualToString:@"Playing"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshPlaying:)])
            [self.delegate refreshPlaying:@"Playing"];

        [self updateAlbumArt];
    }
    else if ([playing isEqualToString:@"Paused"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshPlaying:)])
            [self.delegate refreshPlaying:@"Paused"];
        
        [self updateAlbumArt];
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshPlaying:)])
            [self.delegate refreshPlaying:@"Unknown"];
        
        [self updateAlbumArt];
    }
}

- (void)radioStateChanged:(Radio *)radio
{
    RadioState state = [_radio radioState];
    if(state == kRadioStateConnecting) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(radioStateChanged:)])
            [self.delegate radioStateChanged:kRadioStateBuffering];
    }
    else if(state == kRadioStateBuffering) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotPlaying" object:nil];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(radioStateChanged:)])
            [self.delegate radioStateChanged:kRadioStateBuffering];
    }
    else if(state == kRadioStatePlaying) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isPlaying" object:nil];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(radioStateChanged:)])
            [self.delegate radioStateChanged:kRadioStatePlaying];
        
        NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];
        
        [playerStatus setObject:@"Playing" forKey:@"Player"];
    }
    else if(state == kRadioStateStopped) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotPlaying" object:nil];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(radioStateChanged:)])
            [self.delegate radioStateChanged:kRadioStateStopped];
        
        NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];
        
        [playerStatus setObject:@"Stopped" forKey:@"Player"];
    }
    else if(state == kRadioStateError) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNotPlaying" object:nil];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(radioStateChanged:)])
            [self.delegate radioStateChanged:kRadioStateError];
        
        NSUserDefaults *playerStatus = [NSUserDefaults standardUserDefaults];
        
        [playerStatus setObject:@"Stopped" forKey:@"Player"];
    }
    
    RadioError error = [_radio radioError];
    if(error == kRadioErrorAudioQueueBufferCreate) {
        
    } else if(error == kRadioErrorAudioQueueCreate) {
        
        NSLog(@"kRadioErrorAudioQueueCreate");
        
    } else if(error == kRadioErrorAudioQueueEnqueue) {
        
        NSLog(@"kRadioErrorAudioQueueEnqueue");
        
    } else if(error == kRadioErrorAudioQueueStart) {
        
        NSLog(@"kRadioErrorAudioQueueStart");
        
    } else if(error == kRadioErrorFileStreamGetProperty) {
        
        NSLog(@"kRadioErrorFileStreamGetProperty");
        
    } else if(error == kRadioErrorFileStreamOpen) {
        NSLog(@"kRadioErrorFileStreamOpen");
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Station Currently Offline" message:@"The selected station is currently offline. Please check back later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        */
    } else if(error == kRadioErrorPlaylistParsing) {
        
        NSLog(@"kRadioErrorPlaylistParsing");
        
    } else if(error == kRadioErrorDecoding) {
        
        NSLog(@"kRadioErrorDecoding");
        
    } else if(error == kRadioErrorHostNotReachable) {
        
        NSLog(@"kRadioErrorHostNotReachable");
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Station Currently Offline" message:@"The selected station is currently offline. Please check back later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        */
    } else if(error == kRadioErrorNetworkError) {
        NSLog(@"kRadioErrorNetworkError");

        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Station Currently Offline" message:@"The selected station is currently offline. Please check back later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
         */
    }
}

- (void)radioMetadataReady:(Radio *)radio
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(radioMetadataReady:)]) {
        if ([[radio radioName] isKindOfClass:[NSNull class]] || [radio radioName] == nil) {
            [self.delegate radioMetadataReady:[NSString stringWithFormat:@"%@", [radio radioGenre]]];
        }
        else if ([[radio radioGenre] isKindOfClass:[NSNull class]] || [radio radioGenre] == nil) {
            [self.delegate radioMetadataReady:[NSString stringWithFormat:@"%@", [radio radioName]]];
        }
        else {
            [self.delegate radioMetadataReady:[NSString stringWithFormat:@"%@ - %@", [radio radioName], [radio radioGenre]]];
        }
    }
}

- (void)radioTitleChanged:(Radio *)radio
{
    NSString *streamArtist;
    NSString *streamTitle;
    NSString *streamAlbum;
    
    NSLog(@"radio title %@", [radio radioTitle]);
    
    NSArray *streamParts = [[radio radioTitle] componentsSeparatedByString:@" - "];
    if ([streamParts count] > 0) {
        streamArtist = [streamParts objectAtIndex:0];
    } else {
        streamArtist = @"";
        
    }
    // this looks odd but not every server will have all artist hyphen title
    streamTitle = @"";
    streamAlbum = @"";
    
    if ([streamParts count] >= 2) {
        streamTitle = [streamParts objectAtIndex:1];
        if ([streamParts count] >= 3) {
            for (int nIdx = 2; nIdx < streamParts.count; nIdx++) {
                streamTitle = [streamTitle stringByAppendingString:@" - "];
                streamTitle = [streamTitle stringByAppendingString:streamParts[nIdx]];
            }
        }
    } else {
        streamTitle = @"";
        streamAlbum = @"";
    }

    /*
    if ([streamParts count] >= 2) {
        streamTitle = [streamParts objectAtIndex:1];
        if ([streamParts count] >= 3) {
            streamAlbum = [streamParts objectAtIndex:2];
        } else {
            streamAlbum = @"";
        }
    } else {
        streamTitle = @"";
        streamAlbum = @"";
    }
     */
    
    _metadataArtist = [NSString stringWithFormat:@"%@", streamArtist];
    _metadataTitle = [NSString stringWithFormat:@"%@", streamTitle];
    _metadataAlbum = [NSString stringWithFormat:@"%@", streamAlbum];

    if (self.delegate && [self.delegate respondsToSelector:@selector(radioInfoWithTitle:withArtist:)]) {
        [self.delegate radioInfoWithTitle:_metadataTitle withArtist:_metadataArtist];
        /*
        if (_metadataArtist.length != 0 && _metadataTitle.length != 0)
            [self.delegate radioInfoWithTitle:_metadataTitle withArtist:_metadataArtist];
        */
    }
    
    [self updateAlbumArt];
}

- (void)updateAlbumArt
{
    // NSLog(@"Update Album Art");
    
    NSString *artistSearch = [_metadataArtist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // comment this code out if using the below method
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=%@&api_key=%@&format=json", artistSearch, LAST_FM_API_KEY]]];
    
    // uncomment to get album that goes with current track
    // NSString *albumSearch = [metadataTitle.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // uncomment to get album that goes with current track
    // NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=album.getinfo&album=%@&artist.getinfo&artist=%@&api_key=%@&format=json", albumSearch, artistSearch, LAST_FM_API_KEY]]];
    
    // NSLog(@"%@", theRequest);
    
    self.connection = [[NSURLConnection alloc]
                       initWithRequest:theRequest
                       delegate:self startImmediately:NO];
    
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
    
    if(self.connection){
        
        self.responseData = [[NSMutableData alloc] init];
        
        [self.connection start];
        
        // NSLog (@"Successful");
        
    } else {
        
        // NSLog (@"Failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /*
    NSError *error = nil;
    if(self.responseData == nil)
    {
        // NSLog(@"responseData reported nil!");
    }
    else
    {
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves  error:&error];

        NSArray *artistInfo = [res objectForKey:@"artist"];
        
        // uncomment to get album that goes with current track
        // NSArray *albumInfo = [res objectForKey:@"album"];
        
        NSArray *albumArtURL = [artistInfo valueForKey:@"image"];
        NSArray *mega = [albumArtURL objectAtIndex:4];
        
        NSURL *albumArtUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [mega valueForKey:@"#text"]]];
        NSLog(@"album url ========= %@", albumArtUrl);
    }
    */
    
    [self.responseData setLength:0];
    
    // NSLog (@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.responseData = nil;
    
    NSString *msg = [NSString stringWithFormat:@"Failed: %@", [error description]];
    NSLog (@"%@",msg);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    if(self.responseData == nil)
    {
        // NSLog(@"responseData reported nil!");
    }
    else
    {
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves  error:&error];
        
        NSLog(@"%@", res);
        
        // clear the connection & the buffer
        self.connection = nil;
        self.responseData = nil;
    }
}

@end
