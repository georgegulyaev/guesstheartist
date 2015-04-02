//
//  ImageFinder.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/25/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "ImageFinder.h"

@implementation ImageFinder

 /*
 /  Finds where the image file exists. Returns UIImage object
 /  Native images (for base pack) are stored in the MainBundle resource directory
 /  Images from downloaded packs are stored in Documents directory
 */
+(UIImage *)getImage:(NSString *)image {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier]; //app bundle ID
    
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:image];
    NSString *documentsPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:bundleID] stringByAppendingPathComponent:image];

    //image is in Main Bundle
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
        return [UIImage imageWithContentsOfFile:resourcePath];
    //image is in Documents Folder
    else if ([[NSFileManager defaultManager] fileExistsAtPath:documentsPath])
        return [UIImage imageWithContentsOfFile:documentsPath];
    
    return nil;
}

@end
