//
//  GTAShowGuessedPaintingVC.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/6/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAShowGuessedPaintingVC.h"
#import "GTAGuessedPaintingsTVC.h"
#import "Painting.h"
#import "CoreDataManager.h"

#define iphone5orHigher ([UIScreen mainScreen].bounds.size.width >= 568)
#define iphone4 ([UIScreen mainScreen].bounds.size.width < 568)
#define isAtLeast61 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.1);

@interface GTAShowGuessedPaintingVC ()

@property (strong, nonatomic) IBOutlet UIImageView *rootImageView;
@property (weak, nonatomic) IBOutlet UIImageView *reflection;
@property (weak, nonatomic) IBOutlet UIImageView *paintingView;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (weak, nonatomic) IBOutlet UILabel *captionTitle;
@property (weak, nonatomic) IBOutlet UILabel *infoTitle;
@property (weak, nonatomic) IBOutlet UILabel *infoYear;
@property (weak, nonatomic) IBOutlet UILabel *infoStyle;
@property (weak, nonatomic) IBOutlet UILabel *infoLocation;
@property (weak, nonatomic) IBOutlet UITextView *infoAbout;
@property (weak, nonatomic) IBOutlet UIButton *close;
@property (weak, nonatomic) IBOutlet UIButton *open;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *lights;
@property (weak, nonatomic) IBOutletCollection(UILabel) NSMutableArray *captions;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UILabel *paintingTitle;


@end

@implementation GTAShowGuessedPaintingVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
    [self.rootImageView setContentMode:UIViewContentModeScaleAspectFill];
    if (iphone4) {
        NSLog(@"iphone 4");
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone4"];
    } else if (iphone5orHigher) {
         NSLog(@"iphone 5");
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone5"];
    }
    
    
    
    self.infoView.hidden = YES; //•
    self.paintingTitle.text = self.infoTitle.text = [NSString stringWithFormat:@" 🚬🐴 %@ ", self.painting.title];
    [self.paintingTitle sizeToFit];
    self.infoYear.text = self.painting.year;
    self.infoStyle.text = self.painting.style;
    self.infoLocation.text = (self.painting.location) ? self.painting.location : @"No information.";
    
    self.paintingView.contentMode = UIViewContentModeScaleAspectFit;
    self.paintingView.autoresizingMask =(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    NSString *fileName = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], self.painting.image];
    self.paintingView.image = [UIImage imageWithContentsOfFile:fileName];

    


}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    self.view = nil;
    [self.view removeFromSuperview];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openInfo:(id)sender {
    [UIImageView animateWithDuration:0.6 animations:^{
        [UIImageView animateWithDuration:0.2 animations:^{
            [[self.lights objectAtIndex:0] setAlpha:0.0];
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.2 animations:^{
                [[self.lights objectAtIndex:1] setAlpha:0.0];
            } completion:^(BOOL finished) {
                [UIImageView animateWithDuration:0.2 animations:^{
                    [[self.lights objectAtIndex:2] setAlpha:0.0];
                }];
            }];
        }];
        self.paintingView.alpha = 0.3;
        self.reflection.alpha = 0;
        self.paintingTitle.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.infoView.hidden = NO;
        self.infoView.alpha = 0;
        //[[self.lights objectAtIndex:1] setAlpha:0.5];
        [UIImageView animateWithDuration:1.0 animations:^{
            self.infoView.alpha = 1.0;
            //self.paintingViewSmall.alpha = 1.0;
            //[[self.lights objectAtIndex:1] setAlpha:1.0];
        }];
        
    }];
    /*
    
    //animation
    [UIImageView animateWithDuration:0.2 animations:^{ //turning 3rd light off, fading out reflection and the artwork to 70%
        self.back.alpha = 0;
        self.paintingTitle.alpha = 0;
        
        self.reflection.alpha = 0.7;
        self.paintingView.alpha = 0.7;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.2 animations:^{ //turning 2st light off, fading out reflection and the artwork to 50%
            [[self.lights objectAtIndex:1] setAlpha:0.0];
            self.reflection.alpha = 0.5;
            self.paintingView.alpha = 0.5;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.2 animations:^{ //turning 1st light off, fading out reflection to 0 and the artwork to 30%
                [[self.lights objectAtIndex:0] setAlpha:0.0];
            } completion:^(BOOL finished) {
               
            }];
        }];
    }];*/
    
    
    
}
- (IBAction)closeInfo:(id)sender {
    
    [UIImageView animateWithDuration:1.0 animations:^{
        self.infoView.alpha = 0;
        [[self.lights objectAtIndex:1] setAlpha:0];
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:1.0 animations:^{
            self.infoView.hidden = YES;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.2 animations:^{
                self.back.alpha = 1.0;
                self.paintingTitle.alpha = 1.0;
                [[self.lights objectAtIndex:2] setAlpha:1.0];
                self.reflection.alpha = 0.5;
                self.paintingView.alpha = 0.5;
            } completion:^(BOOL finished) {
                [UIImageView animateWithDuration:0.2 animations:^{
                    [[self.lights objectAtIndex:1] setAlpha:1.0];
                    //self.rootImageView.alpha = 0.7;
                    self.reflection.alpha = 0.7;
                    self.paintingView.alpha = 0.7;
                } completion:^(BOOL finished) {
                    [UIImageView animateWithDuration:0.2 animations:^{
                        [[self.lights objectAtIndex:0] setAlpha:1.0];
                        //self.rootImageView.alpha = 1.0;
                        self.reflection.alpha = 1.0;
                        self.paintingView.alpha = 1.0;
                    }];
                }];
            }];
        }];
    }];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SubGuessedInfoToSubGuessed"]) {
        GTAGuessedPaintingsTVC  *destanationController = (GTAGuessedPaintingsTVC *)segue.destinationViewController;
        destanationController.artist = self.painting.author;
    }
}

@end
