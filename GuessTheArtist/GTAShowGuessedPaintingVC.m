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

#define iphone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define iphone4 ([UIScreen mainScreen].bounds.size.height == 480)
#define isAtLeast61 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.1);

@interface GTAShowGuessedPaintingVC ()

@property (strong, nonatomic) IBOutlet UIImageView *rootImageView;
@property (strong, nonatomic) IBOutlet UIImageView *reflection;
@property (strong, nonatomic) IBOutlet UIImageView *paintingView;
@property (strong, nonatomic) IBOutlet UIImageView *paintingViewSmall;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *infoTitle;
@property (strong, nonatomic) IBOutlet UILabel *infoYear;
@property (strong, nonatomic) IBOutlet UILabel *infoStyle;
@property (strong, nonatomic) IBOutlet UILabel *infoLocation;
@property (strong, nonatomic) IBOutlet UITextView *infoAbout;
@property (strong, nonatomic) IBOutlet UIButton *close;
@property (strong, nonatomic) IBOutlet UIButton *open;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *lights;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *captions;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIButton *back;
@property (strong, nonatomic) IBOutlet UILabel *paintingTitle;


@end

@implementation GTAShowGuessedPaintingVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iphone4) {
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone4"];
    } else if (iphone5) {
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone5"];
    }
    
    self.infoTitle.font = self.infoYear.font = self.infoStyle.font = self.infoLocation.font = self.infoAbout.font =[UIFont fontWithName:@"MyriadPro-Regular" size:14];
    self.paintingTitle.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
    
    self.infoView.hidden = YES;
    self.paintingTitle.text = self.painting.title;
    self.infoTitle.text = [NSString stringWithFormat:@"%@\n\n", self.painting.title];
    self.infoYear.text = self.painting.year;
    self.infoStyle.text = [NSString stringWithFormat:@"%@\n\n", self.painting.style];
    self.infoLocation.text = (self.painting.location) ? [NSString stringWithFormat:@"%@\n\n", self.painting.location] : @"No information.\n\n";
    
    self.paintingView.contentMode = UIViewContentModeScaleAspectFit;
    self.paintingView.autoresizingMask =(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    NSString *fileName = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], self.painting.image];
    self.paintingView.image = [UIImage imageWithContentsOfFile:fileName];
    
    for (UILabel *label in self.captions) {
        [label setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12]];
    }
    
    CGRect currentFrame = self.infoTitle.frame;
    CGSize max = CGSizeMake(self.infoTitle.frame.size.width, 28);
    CGSize expected = [self.infoTitle.text sizeWithFont:self.infoTitle.font constrainedToSize:max lineBreakMode:self.infoTitle.lineBreakMode];
    currentFrame.size.height = expected.height;
    self.infoTitle.frame = currentFrame;
    


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


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[GTAGuessedPaintingsTVC class]]) {
        if ([segue.identifier isEqualToString:@"back"]) {
            GTAGuessedPaintingsTVC  *gtaSGPVC = (GTAGuessedPaintingsTVC *)segue.destinationViewController;
            gtaSGPVC.managedObjectContext = self.managedObjectContext;
            gtaSGPVC.artist = self.painting.author;
        }
    }
}



- (IBAction)openInfo:(id)sender {
    NSString *fileName = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], self.painting.image];
    //small image resizing
    self.paintingViewSmall.image = [UIImage imageWithContentsOfFile:fileName];
    [self resizeImage:self.paintingViewSmall];
    self.paintingViewSmall.alpha = 0;
    
    //animation
    [UIImageView animateWithDuration:0.2 animations:^{
        self.back.alpha = 0;
        self.paintingTitle.alpha = 0;
        [[self.lights objectAtIndex:2] setAlpha:0];
        //self.rootImageView.alpha = 0.7;
        self.reflection.alpha = 0.7;
        self.paintingView.alpha = 0.7;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.2 animations:^{
            [[self.lights objectAtIndex:1] setAlpha:0];
            //self.rootImageView.alpha = 0.5;
            self.reflection.alpha = 0.5;
            self.paintingView.alpha = 0.5;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.2 animations:^{
                [[self.lights objectAtIndex:0] setAlpha:0];
                //self.rootImageView.alpha = 0;
                self.reflection.alpha = 0;
                self.paintingView.alpha = 0.3;
            } completion:^(BOOL finished) {
                [UIImageView animateWithDuration:0.6 animations:^{
                    self.paintingView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.infoView.hidden = NO;
                    self.infoView.alpha = 0;
                    self.paintingViewSmall.alpha = 0;
                    //[[self.lights objectAtIndex:1] setAlpha:0.5];
                    [UIImageView animateWithDuration:1.0 animations:^{
                        self.infoView.alpha = 1.0;
                        self.paintingViewSmall.alpha = 1.0;
                        //[[self.lights objectAtIndex:1] setAlpha:1.0];
                    }];
                    
                }];
            }];
        }];
    }];
    
    
    
}
- (IBAction)closeInfo:(id)sender {
    
    [UIImageView animateWithDuration:1.0 animations:^{
        self.infoView.alpha = 0;
        [[self.lights objectAtIndex:1] setAlpha:0];
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:1.0 animations:^{
            self.infoView.hidden = YES;
        } completion:^(BOOL finished) {
            self.paintingViewSmall.image = nil;
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

#pragma mark helper functions

-(void)resizeImage: (UIImageView *)imageView {
    CGSize itemSize;
    if (iphone5) {
        if (self.painting.about) {
            itemSize = CGSizeMake(232, 115);
            self.paintingViewSmall.contentMode = UIViewContentModeTop;
        } else {
            itemSize = CGSizeMake(232, 254);
            self.paintingViewSmall.contentMode = UIViewContentModeBottom;
        }
    } else if (iphone4) {
        if (self.painting.about) {
            itemSize = CGSizeMake(126, 115);
            self.paintingViewSmall.contentMode = UIViewContentModeTop;
        } else {
            itemSize = CGSizeMake(126, 254);
            self.paintingViewSmall.contentMode = UIViewContentModeBottom;
        }
    }
    float widthRatio = itemSize.width/imageView.image.size.width;
    float heightRatio = itemSize.height/imageView.image.size.height;
    
    if(widthRatio > heightRatio)
    {
        itemSize=CGSizeMake(imageView.image.size.width*heightRatio,imageView.image.size.height*heightRatio);
    } else {
        itemSize=CGSizeMake(imageView.image.size.width*widthRatio,imageView.image.size.height*widthRatio);
    }
    
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [imageView.image drawInRect:imageRect];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
}

@end
