//
//  GTAChooseGameViewController.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/20/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTAChooseGameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelGameMode;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnContinueWithBasePack;
@property (weak, nonatomic) IBOutlet UIButton *btnApprentice;
@property (weak, nonatomic) IBOutlet UIButton *btnMaster;

@property (copy, nonatomic) NSString *gameMode;
- (IBAction)play:(id)sender;
- (IBAction)continueWithBasePack:(id)sender;
- (IBAction)chooseMaster:(id)sender;
- (IBAction)chooseApprentice:(id)sender;

@end
