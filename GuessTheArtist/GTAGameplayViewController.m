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
//#import "QuartzCore/CALayer.h"

#define iphone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iphone4 ([UIScreen mainScreen].bounds.size.height == 480)

@interface GTAGameplayViewController ()
//Main view
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIImageView *paintingView;
@property (weak, nonatomic) IBOutlet UIImageView *rootImageView;

@property (strong, nonatomic) NSArray *paintings;
@property (strong, nonatomic) NSMutableArray *artistsAnswers;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *lights;
@property (weak, nonatomic) IBOutlet UIImageView *reflection;
//left menu view
@property (strong, nonatomic) IBOutlet UIView *menuBgView;
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutlet UIButton *btn50_50;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
//"Lifes left..." view
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *livesIcons;
@property (strong, nonatomic) IBOutlet UILabel *score;
@property (strong, nonatomic) IBOutlet UILabel *scoreChange;
@property int livesLeft;
@property (strong, nonatomic) IBOutlet UILabel *scorePanelLabel;

@property BOOL menuIsOpened;
//gesture recognizers
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *menuBgViewTap;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;


@property NSInteger currentStep;


@end

@implementation GTAGameplayViewController {
    int scoreNumber;
    NSString *scoreChanged;
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
    self.progressBar.hidden = YES;
    //[self prepareData];
    [self startGame:0];
    self.menuBgViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuOpenClose:)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [self.paintingView removeFromSuperview];
    [self.reflection removeFromSuperview];
    [self.rootImageView removeFromSuperview];
}

- (void)swiped:(UISwipeGestureRecognizer *)sender {
    if (self.btnSkip.enabled && !self.menuIsOpened)
        [self skipTheStill:nil];
}


- (void)prepareStep {
    //setting buttons
    for (UIButton *btn in self.buttons) {
        btn.hidden = NO;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:0.6];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont fontWithName:@"MyriaPro-Regular" size:14];
    }
    
    self.score.alpha = 0.8;
    for (UIImageView *light in self.lights) {
        light.alpha = 0;
    }
    //setting currentImage
    self.paintingView.alpha = 0;
    self.paintingView.contentMode = UIViewContentModeScaleAspectFit;
    self.paintingView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
    //menu preparation
    self.menuIsOpened = false;
    self.menuBgView.alpha = 0;
    //[self menuOpen:self.menuBtn];
}

- (void)startStep:(int)step {
    [self prepareStep];

    Painting *painting = [self.paintings objectAtIndex:step];
    NSLog(@"%d", step);

    NSString *correctAnswerArtistName = [painting.author.name description];

    NSMutableArray *artistsAnswers = [Artist getShuffledArtists:self.artistsAnswers excludingName:correctAnswerArtistName];
    
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
    //self.paintingView.image = nil;
    NSString *dir = @"";
    if (painting.pack == [NSNumber numberWithInt: 1]) { //base pack, GuessTheArtist.app folder
        dir = [[NSBundle mainBundle] resourcePath];
    } else if (painting.pack == [NSNumber numberWithInt: 2]) { //in-app pack 2, downloads folder
        dir = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads"];
    } else if (painting.pack == [NSNumber numberWithInt: 3]) { //in-app pack 3, downloads folder
        dir = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads/pack3"];
    }
    NSString *fileName = [NSString stringWithFormat: @"%@/%@", dir, painting.image];

    self.paintingView.image = [UIImage imageWithContentsOfFile:fileName];
    //NSLog(@"Frame width: %u", self.paintingView.contentScaleFactor);

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
                
            }];
        }];
    }];
    //NSLog(@"%@",painting.image);
}


- (void)startGame:(int)step {
    
    /*NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    [request setReturnsObjectsAsFaults:NO];
    [request setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"paintings", nil]];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"ANY paintings.level == 1"];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];

    for (NSManagedObject *obj in results) {
        NSLog(@"Painting: %@", [[obj valueForKey:@"name"] description]);
        //for (Painting *paintingObject in [obj mutableSetValueForKey:@"paintings"]) {
            //NSLog(@"%@'s %@", [[obj valueForKey:@"name"] description], [[paintingObject valueForKey:@"title"] description]);
        //}
    }*/
    
    
    //prepare Game
    if (!self.artistsAnswers) // && step < 1
        self.artistsAnswers = [Artist getArtistsForLevel:1 inManagedObjectContext:[CoreDataManager singletonInstance].managedObjectContext];
    else
        self.artistsAnswers = [Artist shuffleArray:self.artistsAnswers];
    
    if (!self.paintings || step > [self.paintings count] - 1) {
        step = 0;
        self.paintings = [Painting loadPaintings:step inManagedObjectContext:[CoreDataManager singletonInstance].managedObjectContext];
    } else
        self.paintings = (NSArray *)[Painting shuffleArray:[[NSMutableArray alloc] initWithArray:self.paintings]];
    
    self.btn50_50.enabled = self.btnSkip.enabled = YES;
    self.btn50_50.alpha = self.btnSkip.alpha = 1.0;
    
    self.livesLeft = 3;
    for (UIImageView *lifeImg in self.livesIcons) {
        lifeImg.alpha = 1.0;
    }
    self.score.text = self.scorePanelLabel.text =  @"0";
    
    //startGame
    self.currentStep = step;
    [self startStep:self.currentStep];
    
    
}

- (void)checkSolution: (UIButton *)sender {
    UIColor *green = [UIColor colorWithRed:3.0/255.0 green:144.0/255.0 blue:9.0/255.0 alpha:0.6];
    UIColor *red = [UIColor colorWithRed:185.0/255.0 green:0 blue:0 alpha:0.6];
    if (sender.tag == 1) {
        [sender setBackgroundColor:green];
        scoreNumber += 25;
        scoreChanged = @"+25";
        self.scoreChange.textColor = [UIColor greenColor];
    } else {
        [sender setBackgroundColor:red];
        for (UIButton *button in self.buttons) {
            if (button.tag == 1) {
                [button setBackgroundColor:green];
                break;
            }
        }
        if (scoreNumber != 0)
            scoreNumber -= 10;
        scoreChanged = @"-10";
        self.scoreChange.textColor = [UIColor redColor];
        [self reduceLives];
    }
    self.scoreChange.alpha = 0;
    self.scoreChange.text = scoreChanged;
    [UIView animateWithDuration:0.7 animations:^{
        self.scoreChange.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scoreChange.alpha = 0;
            scoreChanged = nil;
            self.score.text = self.scorePanelLabel.text = [NSString stringWithFormat:@"%d", scoreNumber];
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    if (self.livesLeft > 0)
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateBeforeNextRound) userInfo:nil repeats:NO];
    else
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animateBeforeFinishingTheGame) userInfo:nil repeats:NO];
    //[self animateBeforeNextRound];
    
}

#pragma mark - Animated actions

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
                [self startStep:++self.currentStep];
            }];
        }];
    }];
    
}

- (void)animateBeforeFinishingTheGame {
    if ([self.paintings count] < self.currentStep + 1) {
        self.currentStep = -1;
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

- (void)animateBeforeNewGame {
    if ([self.paintings count] < self.currentStep + 1) {
        self.currentStep = -1;
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

- (IBAction)menuOpenClose:(id)sender {
    if (!self.menuIsOpened) {
        [self replaceLeftConstraintOnView:self.menuView withConstant:0.0];
        [self animateConstraintsOpen];
    } else {
        [self replaceLeftConstraintOnView:self.menuView withConstant:-76.0];
        [self animateConstraintsClose];
    }
}

- (IBAction)restartGame:(id)sender {
    [self menuOpenClose:sender];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animateBeforeNewGame) userInfo:nil repeats:NO];
    
    //[self startGame:0];
}

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

- (IBAction)skipTheStill:(id)sender {
    //add if skipIsAvailable marker
    self.btnSkip.enabled = NO;
    self.btnSkip.alpha = 0.5;
    if (sender)
        [self menuOpenClose:sender];
    [self animateBeforeNextRound];
}

- (IBAction)quitGame:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Methods

- (void)replaceLeftConstraintOnView:(UIView *)view withConstant:(float)constant
{
    [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {

        if (constraint.firstItem == view && constraint.firstAttribute == NSLayoutAttributeLeading) {
            [constraint setConstant:constant];
        }
    }];
    self.menuIsOpened = !self.menuIsOpened;
}

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

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
        if (self.btn50_50.enabled && !self.menuIsOpened)
            [self hideTwoRandomAnswers:nil];
}


@end
