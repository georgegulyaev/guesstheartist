//
//  GTAViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/4/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAGameplayViewController.h"
#import "GTAHomeScreenViewController.h"
#import "CoreDataManager.h"
#import "ImageFinder.h"

#define iphone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iphone4 ([UIScreen mainScreen].bounds.size.height == 480)

NSString const *gameModeZen = @"ZEN";
NSString const *gameModeFever = @"FEVER";
float const secondsLeft = 12;

@interface GTAGameplayViewController ()
//Main view
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIImageView *paintingView;
@property (weak, nonatomic) IBOutlet UIImageView *rootImageView;

@property (strong, nonatomic) NSArray *paintings;
@property (strong, nonatomic) NSMutableArray *artistsAnswers;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *lights;
@property (weak, nonatomic) IBOutlet UIImageView *reflection;
//Left slide menu view
@property (weak, nonatomic) IBOutlet UIView *menuBgView;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *btn50_50;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UILabel *labelSecondsLeft;
//"Lifes left..." view
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *livesIcons;
@property (strong, nonatomic) IBOutlet UILabel *score;
@property int livesLeft;
@property (strong, nonatomic) IBOutlet UILabel *scorePanelLabel;
@property (weak, nonatomic) IBOutlet UIView *bgScoreView;
@property (weak, nonatomic) IBOutlet UIView *livesView;

@property BOOL menuIsOpened;

//gesture recognizers
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *menuBgViewTap;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (weak, nonatomic) Painting *currentPainting;


@property NSInteger currentArtworkNumber;



@end

@implementation GTAGameplayViewController {
    int scoreNumber;
    NSString *scoreChanged;
    NSTimer *timer;
    BOOL feverMode;
    BOOL viewDidDisappear;
    float secondsCounter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone5"];
    if (iphone4) {
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone4"];
        NSLog(@"iphone4");
    } else if (iphone5) {
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone5"];
        NSLog(@"iphone5");
    }

    /* setting the progress bar depending on the game type: ZEN/FEVER
    /  if pack variable is available, then ZEN mode selected
    */
    if (self.pack) { //ZEN mode selected
        self.progressBar.hidden = YES;
        feverMode = false;
    } else { //FeverMode selected
        self.progressBar.hidden = NO;
        self.progressBar.trackTintColor = [UIColor redColor];
        feverMode = true;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countDownStart) name:@"appIsActive" object:nil];
    }
    
    /* start the game with the 1st artwork */
    [self startGame:0];
    
    /* setting Gesture recognizers */
    self.menuBgViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuOpenClose:)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self destroyTimerIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    viewDidDisappear = true;
    [self.paintingView removeFromSuperview];
    [self.reflection removeFromSuperview];
    [self.rootImageView removeFromSuperview];
}

- (void)swiped:(UISwipeGestureRecognizer *)sender {
    if (self.btnSkip.enabled && !self.menuIsOpened)
        [self skipTheStill:nil];
}


- (void)prepareGameUI {
    [self destroyTimerIfNeeded];
    [self replaceLeftConstraintOnView:self.menuView withConstant:-76.0];
    /* setting buttons default color */
    for (UIButton *btn in self.buttons) {
        btn.hidden = NO;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:0.6];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.userInteractionEnabled = NO;
    }
    
    //self.score.alpha = 0.8;
    /* keeping lights off */
    for (UIImageView *light in self.lights) {
        light.alpha = 0;
    }
    /* setting artwork canvas content mode */
    self.paintingView.alpha = 0;
    self.paintingView.contentMode = UIViewContentModeScaleAspectFit;
    self.paintingView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
    
    /* keep sliding menu closed by default */
    self.menuIsOpened = false;
    self.menuBgView.alpha = 0;
    //[self menuOpen:self.menuBtn];
}

/* showing current artwork to guess */
- (void)showArtworkToGuess:(int)artworkID {

    [self prepareGameUI];
    
    /* select Artwork */
    self.currentPainting = [self.paintings objectAtIndex:artworkID];

    /* set correct answer: artist name */
    NSString *correctAnswerArtistName = [self.currentPainting.author.name description];
    
    /* add 3 more possible answers: artists names */
    NSMutableArray *artistsAnswers = [Artist getShuffledArtists:self.artistsAnswers excludingName:correctAnswerArtistName];
    
    /* display answers as button.text tagging the right answer with tag=1 */
    int i = 0;
    for (UIButton *btn in self.buttons) {
        [btn setTitle:[artistsAnswers objectAtIndex:i] forState:UIControlStateNormal];
        if ([correctAnswerArtistName isEqualToString:[artistsAnswers objectAtIndex:i]])
            [btn setTag:1];
        else
            [btn setTag:0];
        [btn addTarget:self action:@selector(checkSolution:) forControlEvents:UIControlEventTouchUpInside];
        i ++;
    }
    
    /* set current artwork */
    self.paintingView.image = [ImageFinder getImage:self.currentPainting.image];

    /* show current artwork provided by lights animation */
    [UIImageView animateWithDuration:0.1 animations:^{
        [[self.lights objectAtIndex:2] setAlpha:1];
        self.paintingView.alpha = self.reflection.alpha = 0.22;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.1 animations:^{
            [[self.lights objectAtIndex:1] setAlpha:1];
            self.paintingView.alpha = self.reflection.alpha = 0.55;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.1 animations:^{
                [[self.lights objectAtIndex:0] setAlpha:1];
                self.paintingView.alpha = self.reflection.alpha = 1;
            } completion:^(BOOL finished) {
                /* start countdown if needed */
                if (feverMode) {
                    [self destroyTimerIfNeeded];
                    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) //if FeverMode and App is not in the background mode
                        [self countDownStart];
                }
                /* setting buttons response */
                for (UIButton *btn in self.buttons) {
                    btn.userInteractionEnabled = YES;
                }
            }];
        }];
    }];
}

/* starting the game */
- (void)startGame:(int)artworkNumber {
    /* get artists list depending on number of packs included */

    NSMutableArray *arrayOfPacksIDs = nil;
    if (self.pack) //if pack is passed, then game mode is Zen
        arrayOfPacksIDs = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", (int)self.pack], nil];
    else { //else the mage mode is Fever
        /* set number Packs included */
        arrayOfPacksIDs = [[NSMutableArray alloc] initWithObjects:@1, nil];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisSelected"])
            [arrayOfPacksIDs addObject:@2];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisSelected"])
            [arrayOfPacksIDs addObject:@3];
    }
    NSLog(@"Level: %d", (int)self.level);
    
    /* If the game just began, then get Artists list */
    if (!self.artistsAnswers)
        self.artistsAnswers = [Artist getArtistsForPacks:arrayOfPacksIDs andLevel:self.level inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    else //or just shuffle the existing list of artists
        self.artistsAnswers = [Artist shuffleArray:self.artistsAnswers];
    
    /* If the game just began, then get Paintings list */
    if (!self.paintings) {
        self.paintings = [Painting loadPaintingsForPacks:arrayOfPacksIDs andLevel:self.level inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    } else //or just shuffle the existing list of artists
        self.paintings = (NSArray *)[Painting shuffleArray:[[NSMutableArray alloc] initWithArray:self.paintings]];
    
    /* Enable 50/50 and `Skip` hint buttons */
    self.btn50_50.enabled = self.btnSkip.enabled = YES;
    self.btn50_50.alpha = self.btnSkip.alpha = 1.0;
    
    /* set initial number of lifes to 3 */
    self.livesLeft = 3;
    for (UIImageView *lifeImg in self.livesIcons) {
        lifeImg.alpha = 1.0;
    }
    /* set start score to 0 */
    self.score.text = self.scorePanelLabel.text =  @"0";
    
    /* start game by showing first Artwork to guess */
    self.currentArtworkNumber = artworkNumber;
    [self showArtworkToGuess: (int)self.currentArtworkNumber];
}

/* start 15 seconds countdown updating Progress view */
- (void)countDownStart {
    NSLog(@"start");
    if (!timer && !viewDidDisappear) {
        self.progressBar.progress = 1;
        //float time = 1.0f;
        secondsCounter = secondsLeft;
        self.labelSecondsLeft.text = [NSString stringWithFormat:@"0:%d", (int)secondsLeft];
        /* let the timer work in the background */
        UIBackgroundTaskIdentifier bgTask =0;
        UIApplication  *app = [UIApplication sharedApplication];
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
        }];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
}

/* selector method for decreasing seconds */
- (void)countDown {
    if (--secondsCounter == 0) {
        for (UIButton *button in self.buttons) {
            button.userInteractionEnabled = NO;
        }
        [self checkSolution:nil];
    }
    
    self.progressBar.progress = secondsCounter/secondsLeft;
    self.labelSecondsLeft.text = (secondsCounter < 10) ? [NSString stringWithFormat:@"0:0%d", (int)secondsCounter] : [NSString stringWithFormat:@"0:%d", (int)secondsCounter];
}

- (void)destroyTimerIfNeeded {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

/* Check selected answer */
- (void)checkSolution: (UIButton *)sender {
    
    [self destroyTimerIfNeeded];
    
    if (self.menuIsOpened)
        [self menuOpenClose:nil];
    /*show right answer button in green */
    for (UIButton *button in self.buttons) {
        button.userInteractionEnabled = NO;
    }
    
    UIColor *green = [UIColor colorWithRed:3.0/255.0 green:144.0/255.0 blue:9.0/255.0 alpha:0.6];
    UIColor *red = [UIColor colorWithRed:185.0/255.0 green:0 blue:0 alpha:0.6];
    if (sender.tag == 1) { //if right answer selected
        
        scoreNumber += 25; //increase score to 25 by default
        
        [sender setBackgroundColor:green]; //set answer button to green
        
        //to-do move to -addBonus method
        /* update bonus view constraints */
        self.score.textColor = [UIColor greenColor];
        [self.livesView.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
            
            if (constraint.secondItem == self.bgScoreView && constraint.firstAttribute == NSLayoutAttributeTrailing) {
                [constraint setConstant:103];
            }
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            /* animate bonus view */
            self.bgScoreView.alpha = 1;
            [self.livesView layoutIfNeeded];
        } completion:^(BOOL finished) {
            /* animate constraints */
            [UIView animateWithDuration:0.1 delay: 0.4 options:UIViewAnimationOptionTransitionNone animations:^{
                self.bgScoreView.alpha = 0;
            } completion:^(BOOL finished) {
                /* update constraints back to initial value */
                [self.livesView.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
                    
                    if (constraint.secondItem == self.bgScoreView && constraint.firstAttribute == NSLayoutAttributeTrailing) {
                        [constraint setConstant:70.0];
                    }
                    /* update score color */
                    self.score.textColor = [UIColor whiteColor];
                }];
            }];
        }];
        
        /* mark painting as guessed */
        if (self.currentPainting.guessed != [NSNumber numberWithInt:1]) {
            self.currentPainting.guessed = [NSNumber numberWithInt:1];
            NSError *err;
            [[CoreDataManager sharedInstance].managedObjectContext save:&err];
        }
    } else { //if wrong answer selected
        if (sender) {
            [sender setBackgroundColor:red]; //set answer button to red
            
            /*show right answer button in green */
            for (UIButton *button in self.buttons) {
                if (button.tag == 1) {
                    [button setBackgroundColor:green];
                    break;
                }
            }
        }
        /* reduce lives by disabling one of the lives icons */
        [self reduceLives];
    }
    /* update score value */
    [UIView animateWithDuration:0.7 animations:^{
        
        self.score.text = self.scorePanelLabel.text = [NSString stringWithFormat:@"%d", scoreNumber];
    }];

    /* Set Time Interval before switching screens */
    if (self.livesLeft > 0)
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateBeforeNextRound) userInfo:nil repeats:NO];
    else
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animateBeforeFinishingTheGame) userInfo:nil repeats:NO];
}

#pragma mark - Animated actions

/* Animation of lights and Artwork image view between rounds */
- (void)animateBeforeNextRound {
    [UIImageView animateWithDuration:0.1 animations:^{
        [[self.lights objectAtIndex:2] setAlpha:0];
        self.paintingView.alpha = self.reflection.alpha = 0.66;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.1 animations:^{
            [[self.lights objectAtIndex:1] setAlpha:0];
            self.paintingView.alpha = self.reflection.alpha = 0.33;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.1 animations:^{
                [[self.lights objectAtIndex:0] setAlpha:0];
                self.paintingView.alpha = self.reflection.alpha = 0;
            } completion:^(BOOL finished) {
                [self showArtworkToGuess:++self.currentArtworkNumber];
            }];
        }];
    }];
    
}

/* Animation of lights and Artwork image before showing GameOver screen */
- (void)animateBeforeFinishingTheGame {
    
    [self destroyTimerIfNeeded];
    
    if ([self.paintings count] < self.currentArtworkNumber + 1) {
        self.currentArtworkNumber= -1;
    }
    
    [UIImageView animateWithDuration:0.1 animations:^{
        [[self.lights objectAtIndex:2] setAlpha:0];
        self.paintingView.alpha = self.reflection.alpha = 0.66;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.1 animations:^{
            [[self.lights objectAtIndex:1] setAlpha:0];
            self.paintingView.alpha = self.reflection.alpha = 0.33;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.1 animations:^{
                [[self.lights objectAtIndex:0] setAlpha:0];
                self.paintingView.alpha = self.reflection.alpha = 0;
            } completion:^(BOOL finished) {
                [self performSegueWithIdentifier:@"GameplayToHome" sender:nil];
                //[self startGame:0];
            }];
        }];
    }];
}

/* Animation of lights and Artwork image view before the game start */
- (void)animateBeforeNewGame {
    
    [self destroyTimerIfNeeded];
    
    if ([self.paintings count] < self.currentArtworkNumber + 1) {
        self.currentArtworkNumber = -1;
    }
    [UIImageView animateWithDuration:0.1 animations:^{
        [[self.lights objectAtIndex:2] setAlpha:0];
        self.paintingView.alpha = self.reflection.alpha = 0.66;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.1 animations:^{
            [[self.lights objectAtIndex:1] setAlpha:0];
            self.paintingView.alpha = self.reflection.alpha = 0.33;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.1 animations:^{
                [[self.lights objectAtIndex:0] setAlpha:0];
                self.paintingView.alpha = self.reflection.alpha = 0;
            } completion:^(BOOL finished) {
                scoreNumber = 0;
                [self startGame:0];
            }];
        }];
    }];
}

/* Reduce lifes by disabling lifes icons */
- (void)reduceLives {
    self.livesLeft--;
    
    switch (self.livesLeft) {
        case 2: {
            NSLog(@"Lives2: %d", self.livesLeft);
            [UIImageView animateWithDuration:0.5 animations:^{
                [[self.livesIcons objectAtIndex:0] setAlpha:0];
            }];
            break;
        }
        case 1: {
            NSLog(@"Lives1: %d", self.livesLeft);
            [UIImageView animateWithDuration:0.5 animations:^{
                [[self.livesIcons objectAtIndex:1] setAlpha:0];
            }];
            break;
        }
        case 0: {
            [UIImageView animateWithDuration:0.5 animations:^{
                [[self.livesIcons objectAtIndex:2] setAlpha:0];
            }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Actions

/* Sliding menu button pressed */
- (IBAction)menuOpenClose:(id)sender {
    if (!self.menuIsOpened) {
        [self replaceLeftConstraintOnView:self.menuView withConstant:0.0];
        [self animateConstraintsOpen];
    } else {
        [self replaceLeftConstraintOnView:self.menuView withConstant:-76.0];
        [self animateConstraintsClose];
    }
}

/* Restart button pressed */
- (IBAction)restartGame:(id)sender {
    
    [self destroyTimerIfNeeded];
    
    [self menuOpenClose:sender];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(animateBeforeNewGame) userInfo:nil repeats:NO];
    
    //[self startGame:0];
}

/* Hide to answers hint button pressed */
- (IBAction)hideTwoRandomAnswers:(id)sender {
    self.btn50_50.enabled = NO;
    self.btn50_50.alpha = 0.5;
    if (self.menuIsOpened)
        [self menuOpenClose:sender];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    int index = 0;
    for (UIButton *btn in self.buttons) {
        if (btn.tag != 1) {
            [tempArray addObject:[NSNumber numberWithInt:index]];
        }
        index ++;
    }
    tempArray = [Painting shuffleArray:tempArray]; //refactor
    [[self.buttons objectAtIndex:[[tempArray objectAtIndex:0] intValue]] setHidden:YES];
    [[self.buttons objectAtIndex:[[tempArray objectAtIndex:1] intValue]] setHidden:YES];
}

/* Skip the artwork hint button pressed */
- (IBAction)skipTheStill:(id)sender {
    
    [self destroyTimerIfNeeded];
    
    //add if skipIsAvailable marker
    self.btnSkip.enabled = NO;
    self.btnSkip.alpha = 0.5;
    if (sender)
        [self menuOpenClose:sender];
    [self animateBeforeNextRound];
}

/* Quit game action */
- (IBAction)quitGame:(id)sender {
    
    [self destroyTimerIfNeeded];
    
}

#pragma mark - Sliding view helpers

/* Updating constraints for sliding view */
- (void)replaceLeftConstraintOnView:(UIView *)view withConstant:(float)constant
{
    [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {

        if (constraint.firstItem == view && constraint.firstAttribute == NSLayoutAttributeLeading) {
            [constraint setConstant:constant];
        }
    }];
    self.menuIsOpened = !self.menuIsOpened;
}

/* Animating of the sliding menu opening */
- (void)animateConstraintsOpen {
    [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"btn_menu_button_selected"] forState:UIControlStateNormal];
    [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"btn_menu_button_pressed"] forState:UIControlStateSelected];
    [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"btn_menu_button_selected"] forState:UIControlStateHighlighted];
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
        self.menuBgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        self.menuBgView.alpha = 1.0;
        [self.menuBgView addGestureRecognizer:(self.menuBgViewTap)];
    }];
}

/* Animating of the sliding menu closing */
- (void)animateConstraintsClose {
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
        self.menuBgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.menuBgView.alpha = 0;
        [self.menuBgView removeGestureRecognizer:self.menuBgViewTap];
    } completion:^(BOOL finished) {
        [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"btn_menu_button_normal"] forState:UIControlStateNormal];
        [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"btn_menu_button_pressed"] forState:UIControlStateSelected];
        [self.menuBtn setBackgroundImage:[UIImage imageNamed:@"btn_menu_button_pressed"] forState:UIControlStateHighlighted];
    }];
}

#pragma mark - motion gestures

/* Device shaking implementation */
- (BOOL) canBecomeFirstResponder {
    return YES;
}

/* Activate 50/50 hint on shake */
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
        if (self.btn50_50.enabled && !self.menuIsOpened)
            [self hideTwoRandomAnswers:nil];
}


@end
