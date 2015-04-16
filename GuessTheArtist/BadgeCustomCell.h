//
//  BadgeCustomCell.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 4/11/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *light;


@end
