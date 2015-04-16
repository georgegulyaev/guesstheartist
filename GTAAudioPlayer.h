//
//  GTAAudioPlayer.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 4/16/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface GTAAudioPlayer : AVAudioPlayer <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
+(GTAAudioPlayer *)sharedInstance;
- (void)playCover;


@end
