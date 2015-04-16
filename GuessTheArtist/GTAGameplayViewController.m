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
#import "GTABadgeDistributor.h"
#import "GTAEndGameViewController.h"
#import "GTAAppDelegate.h"

#define iphone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iphone4 ([UIScreen mainScreen].bounds.size.height == 480)
float const secondsLeft = 12; //Seconds given to guess an artwork in Fever mode

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
//Fact unlock notification view
@property (weak, nonatomic) IBOutlet UIView *factView;
@property (weak, nonatomic) IBOutlet UIImageView *factImgBubble;

@property BOOL menuIsOpened;

//gesture recognizers
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *menuBgViewTap;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) GTABadgeDistributor *badgeDistributor;

@property (weak, nonatomic) Painting *currentPainting;
@property NSInteger currentArtworkNumber;

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)swiped:(UISwipeGestureRecognizer *)sender;
- (void)prepareGameUI;
- (void)startGame;
- (void)showArtworkToGuess:(int)artworkID;
- (void)checkSolution: (UIButton *)sender;
- (void)updateBadgeDistributorArtworks;
- (void)showFactView;
- (void)showBonusView;
- (void)countDownStart;
- (void)countDown;
- (void)destroyTimerIfNeeded;
- (void)animateBeforeNextRound;
- (void)animateBeforeFinishingTheGame;
- (void)animateBeforeNewGame;
- (void)reduceLives;
- (IBAction)menuOpenClose:(id)sender;
- (IBAction)restartGame:(id)sender;
- (IBAction)quitGame:(id)sender;
- (IBAction)hideTwoRandomAnswers:(id)sender;
- (IBAction)skipTheStill:(id)sender;
- (void)updateUserDefaultsScore;
- (void)updateUserDefaultsNumberOfPaintings: (NSUInteger)total;
- (void)replaceLeftConstraintOnView:(UIView *)view withConstant:(float)constant;
- (void)animateConstraintsOpen;
- (void)animateConstraintsClose;
- (BOOL) canBecomeFirstResponder;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@end

@implementation GTAGameplayViewController
{
    int scoreNumber; //Fever game score counter
    NSTimer *timer; //Fever mode timer
    BOOL feverMode; //game mode
    BOOL viewDidDisappear; //flag for Timer deactivation
    float secondsCounter; //Seconds-left counter for Zen mode
    int totalScore; //current game total score for Zen mode
    float timeFor3in5; //time to track 3 artworks guessed in 5 seconds
    int artworks3in5; //number of artworks guessed in 5 seconds in a row
    int artworksWOHints; //number of artworks guessed w/o hints in a row
    NSUInteger totalPaintingsAmount;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    /* setting Gesture recognizers */
    self.menuBgViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuOpenClose:)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:NO];


    self.badgeDistributor = [[GTABadgeDistributor alloc] init];
    
    self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone5"];
    if (iphone4)
    {
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone4"];
        NSLog(@"iphone4");
    }
    else if (iphone5)
    {
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone5"];
        NSLog(@"iphone5");
    }
    
    /* setting the progress bar depending on the game type: ZEN/FEVER
     /  if pack variable is available, then ZEN mode selected
     /  settings score and time counters
     */
    if (self.pack) //ZEN mode selected
    {
        self.progressBar.hidden = YES;
        feverMode = false;
        totalScore = 0;
    } else //FeverMode selected
    {
        self.progressBar.hidden = NO;
        self.progressBar.trackTintColor = [UIColor redColor];
        feverMode = true;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countDownStart) name:@"appIsActive" object:nil];
        timeFor3in5 = artworks3in5 = artworksWOHints = 0;
    }
    
    /* start the game with the 1st artwork */
    [self startGame];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //if (!unwindSegueExecuted)
        //[[GTAAudioPlayer sharedInstance] play];
    
    [super viewWillDisappear:NO];
    if (feverMode)
        [self destroyTimerIfNeeded];
    self.paintings = nil;
    self.artistsAnswers = nil;
    self.lights = nil;
    self.progressBar = nil;
    self.buttons = NULL;
    [self.bgScoreView removeFromSuperview];
    [self.paintingView removeFromSuperview];
    [self.reflection removeFromSuperview];
    [self.rootImageView removeFromSuperview];
    [self.view removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    viewDidDisappear = true;

}

- (void)swiped:(UISwipeGestureRecognizer *)sender
{
    if (self.btnSkip.enabled && !self.menuIsOpened)
        [self skipTheStill:nil];
}


#pragma mark Game process

- (void)prepareGameUI {
    if (feverMode)
        [self destroyTimerIfNeeded];
    
    [self replaceLeftConstraintOnView:self.menuView withConstant:-76.0];
    
    /* setting buttons default color */
    for (UIButton *btn in self.buttons)
    {
        btn.hidden = NO;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:0.6];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.userInteractionEnabled = NO;
    }
    
    /* keeping lights off */
    for (UIImageView *light in self.lights)
        light.alpha = 0;
    
    /* setting artwork canvas content mode */
    self.paintingView.alpha = 0;
    self.paintingView.contentMode = UIViewContentModeScaleAspectFit;
    self.paintingView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
    
    /* keep sliding menu closed by default */
    self.menuIsOpened = false;
    self.menuBgView.alpha = 0;
}

/* Starting the game */
- (void)startGame
{
    //[[GTAAudioPlayer sharedInstance] pause];
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
    
    /* If the game just began, then get Artists list */
    if (!self.artistsAnswers)
        self.artistsAnswers = [Artist getArtistsForPacks:arrayOfPacksIDs andLevel:self.level inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    else //or just shuffle the existing list of artists
        self.artistsAnswers = [Artist shuffleArray:self.artistsAnswers];
    
    /* If the game just began, then get Paintings list */
    if (!self.paintings)
    {
        self.paintings = [Painting loadPaintingsForPacks:arrayOfPacksIDs andLevel:self.level inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    } else //or just shuffle the existing list of artists
        self.paintings = (NSArray *)[Painting shuffleArray:[[NSMutableArray alloc] initWithArray:self.paintings]];
   
    /* count total number of paintings for ZenMode levels VC */
    if (!feverMode)
    {
        if (![[NSUserDefaults standardUserDefaults] integerForKey:@"pack%@level%@PaintingsTotal"])
           totalPaintingsAmount = [self.paintings count];
           [self updateUserDefaultsNumberOfPaintings:totalPaintingsAmount];
    }
    
    /* Enable 50/50 and `Skip` hint buttons */
    self.btn50_50.enabled = self.btnSkip.enabled = YES;
    self.btn50_50.alpha = self.btnSkip.alpha = 1.0;
    
    /* set initial number of lifes to 3 */
    self.livesLeft = 3;
    for (UIImageView *lifeImg in self.livesIcons)
        lifeImg.alpha = 1.0;
    
    /* set start score to 0 */
    self.score.text = self.scorePanelLabel.text =  @"0";
    
    /* start game by showing first Artwork to guess */
    self.currentArtworkNumber = 0;
    [self showArtworkToGuess: (int)self.currentArtworkNumber];
}


/* showing current artwork to guess */
- (void)showArtworkToGuess:(int)artworkID
{
    
    [self prepareGameUI];
    
    /* select Artwork */
    self.currentPainting = [self.paintings objectAtIndex:artworkID];
    
    /* set correct answer: artist name */
    NSString *correctAnswerArtistName = [self.currentPainting.author.name description];
    
    /* add 3 more possible answers: artists names */
    NSMutableArray *artistsAnswers = [Artist getShuffledArtists:self.artistsAnswers excludingName:correctAnswerArtistName];
    
    /* display answers as button.text tagging the right answer with tag=1 */
    int i = 0;
    for (UIButton *btn in self.buttons)
    {
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


/* Check selected answer */
- (void)checkSolution: (UIButton *)sender
{
    if (feverMode)
        [self destroyTimerIfNeeded];
    
    /* close hints menu if opened */
    if (self.menuIsOpened)
        [self menuOpenClose:nil];
    
    /*show right answer button in green */
    for (UIButton *button in self.buttons)
        button.userInteractionEnabled = NO;
    
    UIColor *green = [UIColor colorWithRed:3.0/255.0 green:144.0/255.0 blue:9.0/255.0 alpha:0.6];
    UIColor *red = [UIColor colorWithRed:185.0/255.0 green:0 blue:0 alpha:0.6];
    if (sender.tag == 1)
    { //if right answer selected
        
        scoreNumber += 25; //increase score by 25 by default
        
        if (!feverMode) //if Zen Mode
            totalScore += 1; //increase current game total score for ZenMode
        else { //if FeverMode
            [self updateBadgeDistributorArtworks]; //update FastArtworksData
        }
        
        [sender setBackgroundColor:green]; //set answer button to green
        
        //to-do move to -addBonus method
        [self showBonusView];
        
        [self showFactView];
        
        /* mark painting as guessed */
        if (self.currentPainting.guessed != [NSNumber numberWithInt:1])
        {
            self.currentPainting.guessed = [NSNumber numberWithInt:1];
            NSError *err;
            [[CoreDataManager sharedInstance].managedObjectContext save:&err];
        }
    } else { //if wrong answer selected
        if (sender)
        {
            [sender setBackgroundColor:red]; //set answer button to red
            
            /*show right answer button in green */
            for (UIButton *button in self.buttons)
            {
                if (button.tag == 1) {
                    [button setBackgroundColor:green];
                    break;
                }
            }
        }
        /* reduce lives by disabling one of the lives icons */
        [self reduceLives];
        
        if (feverMode) {
            timeFor3in5 = artworks3in5 = artworksWOHints = 0;
        }

    }
    /* update score value */
    [UIView animateWithDuration:0.7 animations:^{
        
        self.score.text = self.scorePanelLabel.text = [NSString stringWithFormat:@"%d", scoreNumber];
    }];
    
    /*update current zen game best score */
    if (!feverMode)
        [self updateUserDefaultsScore];

    /* Set Time Interval before switching screens */
    if (self.livesLeft > 0)
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateBeforeNextRound) userInfo:nil repeats:NO];
    else
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animateBeforeFinishingTheGame) userInfo:nil repeats:NO];
}

#pragma mark updating Badges Data
- (void)updateBadgeDistributorArtworks
{
    //update FastArtworks data
    if (self.badgeDistributor.numberOfFastArtworksGuessed < 1000 && (secondsLeft - secondsCounter <= 2)) //if artwork was guessed in less than 2 sec
        self.badgeDistributor.numberOfFastArtworksGuessed += 1;
    
    //update 3 artworks in 5 seconds value
    if (self.badgeDistributor.numberOf3ArtworksIn5seconds < 1) {
        if (secondsLeft - secondsCounter <= 5) {
            if (timeFor3in5 + (secondsLeft - secondsCounter) <= 5) {
                timeFor3in5 += secondsLeft - secondsCounter;
                artworks3in5 += 1;
            } else {
                timeFor3in5 = secondsLeft - secondsCounter;
                artworks3in5 = 1;
            }
            if (artworks3in5 == 3) {
                self.badgeDistributor.numberOf3ArtworksIn5seconds = 1;
            }
        }
    }
    
    //update artworks guessed in a row w/o hints value
    if (self.badgeDistributor.numberOfArtworksWOHints < 100) {
        artworksWOHints += 1;
        if (self.badgeDistributor.numberOfArtworksWOHints < artworksWOHints)
            self.badgeDistributor.numberOfArtworksWOHints = artworksWOHints;
    }
}

#pragma mark Bonuses and Scores and Facts animations

/* Fact view animation */
- (void)showFactView {
    NSLog(@"Dali");
    //preparing view constrant for animation
    __block float constr = 0;
    [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        
        if (constraint.firstItem == self.factView && constraint.firstAttribute == NSLayoutAttributeLeading) {
            constr = constraint.constant;
            [constraint setConstant:0.0f];
        }
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        /* animate prepared constrant */
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        /* animate constraints */
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
            self.factImgBubble.alpha = 1;
        } completion:^(BOOL finished) {
            /* update constraints back to initial value */
            [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
                if (constraint.firstItem == self.factView && constraint.firstAttribute == NSLayoutAttributeLeading) {
                    [constraint setConstant:constr];
                }
            }];
            [UIView animateWithDuration:0.2 delay:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.factImgBubble.alpha = 0;
            }];
        }];
    }];
}

/* bonus score view animation */
- (void)showBonusView
{
    self.score.textColor = [UIColor greenColor];
    /* update bonus view constraints */
    __block float constr = 0;
    [self.livesView.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        
        if (constraint.secondItem == self.bgScoreView && constraint.firstAttribute == NSLayoutAttributeTrailing) {
            constr = constraint.constant;
            [constraint setConstant:constr + 33.0f];
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
                    [constraint setConstant:constr];
                }
                /* update score color */
                self.score.textColor = [UIColor whiteColor];
            }];
        }];
    }];
}

#pragma mark Timer

/* start 15 seconds countdown updating Progress view */
- (void)countDownStart {
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
                [self showArtworkToGuess:(int)++self.currentArtworkNumber];
            }];
        }];
    }];
    
}

/* Animation of lights and Artwork image before showing GameOver screen */
- (void)animateBeforeFinishingTheGame {
    
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
                [self quitGame:nil];
            }];
        }];
    }];
}

/* Animation of lights and Artwork image view before the game start */
- (void)animateBeforeNewGame {
    
    if (feverMode)
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
                [self startGame];
            }];
        }];
    }];
}

/* Reduce lifes by disabling lifes icons */
- (void)reduceLives {
    self.livesLeft--;
    
    switch (self.livesLeft) {
        case 2: {
            [UIImageView animateWithDuration:0.5 animations:^{
                [[self.livesIcons objectAtIndex:0] setAlpha:0];
            }];
            break;
        }
        case 1: {
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
    
    if (feverMode)
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
    
    //reset artworksWOHints number
    if (feverMode)
        artworksWOHints = 0;
}

/* Skip the artwork hint button pressed */
- (IBAction)skipTheStill:(id)sender {
    
    if (feverMode) {
        [self destroyTimerIfNeeded];
        artworksWOHints = 0;
    }
    
    //add if skipIsAvailable marker
    self.btnSkip.enabled = NO;
    self.btnSkip.alpha = 0.5;
    if (sender)
        [self menuOpenClose:sender];
    [self animateBeforeNextRound];

}

/* Quit game action */
- (IBAction)quitGame:(id)sender {
    if (feverMode) {
        [self destroyTimerIfNeeded];
        //update number of total games played if game score is more than 300
        if (self.badgeDistributor.numberOfGamesPlayed < 500 && scoreNumber >= 300)
            self.badgeDistributor.numberOfGamesPlayed += 1;
    } else {
        if (self.badgeDistributor.numberOfGamesPlayed < 1 && scoreNumber >= 300)
            self.badgeDistributor.numberOfGamesPlayed += 1;
    }
    [self performSegueWithIdentifier:@"GameplayToEnd" sender:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

/* 
   Setting current game best score for current level (Zen Mode)
   Clearing next level if success rate is > 50%
 */
- (void)updateUserDefaultsScore {
    NSUInteger bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"pack%dlevel%dBestScore", (int)self.pack, (int)self.level]];
    if (bestScore < totalScore)
        [[NSUserDefaults standardUserDefaults] setInteger:totalScore forKey:[NSString stringWithFormat:@"pack%dlevel%dBestScore", (int)self.pack, (int)self.level]];

    //clear next level if needed
    if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"pack%dlevel%dcleared", (int)self.pack, (int)(self.level + 1)]] == false && (self.level + 1) <= 10 && (totalScore * 100 / (int)totalPaintingsAmount) >= 51) {
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"pack%dlevel%dcleared", (int)self.pack, (int)(self.level + 1)]];

    }
    
     [[NSUserDefaults standardUserDefaults] synchronize];
}

/* setting current level number of paintings (Zen Mode) */
- (void)updateUserDefaultsNumberOfPaintings: (NSUInteger)total {
    [[NSUserDefaults standardUserDefaults] setInteger:total forKey:[NSString stringWithFormat:@"pack%dlevel%dPaintingsTotal", (int)self.pack, (int)self.level]];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
- (void)animateConstraintsClose
{
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
- (BOOL) canBecomeFirstResponder
{
    return YES;
}

/* Activate 50/50 hint on shake */
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
        if (self.btn50_50.enabled && !self.menuIsOpened)
            [self hideTwoRandomAnswers:nil];
}

- (IBAction)unwindToGameplay:(UIStoryboardSegue *)unwindSegue
{

}

-(BOOL) canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {

    return NO;
}

@end
