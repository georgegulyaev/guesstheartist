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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self updateChoosePackButtons];
}

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
        GTAGameplayViewController *destinationController = (GTAGameplayViewController *)segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"ChooseGameToGameplay"]) {
            destinationController.gameMode = self.gameMode;
        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)back:(id)sender {
    //[self performSegueWithIdentifier:@"ChooseGameToHome" sender:nil];
}

- (IBAction)play:(id)sender {
    //[self performSegueWithIdentifier:@"ChooseGameToGameplay" sender:nil];
}

- (IBAction)continueWithBasePack:(id)sender {
    //[self performSegueWithIdentifier:@"ChooseGameToGameplayWithPack" sender:nil];
}

- (IBAction)chooseApprentice:(id)sender {
    //change button state only if state the pack is Installed
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"]) {
        BOOL packIsSelected = [[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisSelected"];
        [[NSUserDefaults standardUserDefaults] setBool:!packIsSelected forKey:@"packAPisSelected"];
        [self updateChoosePackButtons];
    } else { //else open `buy pack` page
        [self performSegueWithIdentifier:@"ChooseGameToPacks" sender:nil];
    }
    
}

- (IBAction)chooseMaster:(id)sender {
    //change button state only if state the pack is Installed
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisInstalled"]) {
        BOOL packIsSelected = [[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisSelected"];
        [[NSUserDefaults standardUserDefaults] setBool:!packIsSelected forKey:@"packMPisSelected"];
        [self updateChoosePackButtons];
    } else { //else open `buy pack` page
        [self performSegueWithIdentifier:@"ChooseGameToPacks" sender:nil];
    }
    
}

- (void)updateChoosePackButtons {
    BOOL packAPisInstalled = [[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"];
    BOOL packMPisInstalled = [[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisInstalled"];
    BOOL packAPisSelected = [[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisSelected"];
    BOOL packMPisSelected = [[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisSelected"];
    
    //Setting up Pack selection buttons state
    
    //Apprentice pack select button
    if (packAPisInstalled) {
        if (packAPisSelected) {
            [self.btnApprentice setImage:[UIImage imageNamed:@"btn_apprentice_selected"] forState:UIControlStateNormal];
            [self.btnApprentice setImage:[UIImage imageNamed:@"btn_apprentice_normal"] forState:UIControlStateSelected];
        } else {
            [self.btnApprentice setImage:[UIImage imageNamed:@"btn_apprentice_normal"] forState:UIControlStateNormal];
            [self.btnApprentice setImage:[UIImage imageNamed:@"btn_apprentice_selected"] forState:UIControlStateSelected];
        }
    } else {
        [self.btnApprentice setImage:[UIImage imageNamed:@"btn_apprentice_locked"] forState:UIControlStateNormal|UIControlStateSelected];
    }
    //Master pack select button
    if (packMPisInstalled) {
        if (packMPisSelected) {
            [self.btnMaster setImage:[UIImage imageNamed:@"btn_master_selected"] forState:UIControlStateNormal];
            [self.btnMaster setImage:[UIImage imageNamed:@"btn_master_normal"] forState:UIControlStateSelected];
        } else {
            [self.btnMaster setImage:[UIImage imageNamed:@"btn_master_normal"] forState:UIControlStateNormal];
            [self.btnMaster setImage:[UIImage imageNamed:@"btn_master_selected"] forState:UIControlStateSelected];
        }
    } else {
        [self.btnMaster setImage:[UIImage imageNamed:@"btn_master_locked"] forState:UIControlStateNormal|UIControlStateSelected];
    }
    //buttons play/continue update
    if (packMPisSelected == true || packAPisSelected == true) {
        NSLog(@"YES");
        self.btnContinueWithBasePack.hidden = YES;
        self.btnPlay.hidden = NO;
    }
    if (packMPisSelected == false && packAPisSelected == false)  {
        NSLog(@"YES2");
        self.btnContinueWithBasePack.hidden = NO;
        self.btnPlay.hidden = YES;
    }
    
}
@end
