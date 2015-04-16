//
//  GTAViewController.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/4/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Importer.h"
#import "GTAAudioPlayer.h"

@interface GTAGameplayViewController : UIViewController

@property (copy, nonatomic) NSString *gameMode;
@property NSInteger pack;
@property NSInteger level;


@end
