//
//  GTAChooseGameViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/20/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAChooseGameViewController.h"
#import "GTAGameplayViewController.h"
#import "GTAHomeScreenViewController.h"

@interface GTAChooseGameViewController () {
    NSMutableArray *includedPacksArray;
}

@end

@implementation GTAChooseGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UILabel appearanceWhenContainedIn:[GTAChooseGameViewController class], nil]
     setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:17]];
    self.labelGameMode.text = [NSString stringWithFormat:@"Game Mode: %@", self.gameMode];
    self.btnPlay.hidden = YES;
    self.btnContinueWithBasePack.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[GTAGameplayViewController class]]) {
        GTAGameplayViewController *destanationController = (GTAGameplayViewController *)segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"ChooseGameToGameplay"]) {
            destanationController.gameMode = self.gameMode;
            
        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}




- (IBAction)play:(id)sender {
    [self performSegueWithIdentifier:@"ChooseGameToGameplay" sender:nil];
}

- (IBAction)continueWithBasePack:(id)sender {
    [self performSegueWithIdentifier:@"ChooseGameToGameplay" sender:nil];
}

- (IBAction)chooseMaster:(id)sender {
   // if (self.btnMaster.imageView.image)
}

- (IBAction)chooseApprentice:(id)sender {
}
@end
