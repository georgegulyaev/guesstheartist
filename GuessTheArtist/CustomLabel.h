//
//  CustomLabel.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/14/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface CustomLabel : UILabel

@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;

@end
