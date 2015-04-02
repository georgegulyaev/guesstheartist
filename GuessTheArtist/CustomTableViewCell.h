//
//  CustomTableViewCell.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/29/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDetail;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
