//
//  CustomCell.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/27/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageLock;
@property (weak, nonatomic) IBOutlet UILabel *labelLevelName;
@property (weak, nonatomic) IBOutlet UIImageView *imageStarsBg;
@property (weak, nonatomic) IBOutlet UIImageView *imageFrame;
@property (weak, nonatomic) IBOutlet UILabel *labelGuessed;
@property (weak, nonatomic) IBOutlet UIImageView *imageLight;

@end
