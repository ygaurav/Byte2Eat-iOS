//
// Created by Gaurav Yadav on 16/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "FileManager.h"


@implementation FileManager

+ (BOOL)doesBlurredImageExist:(NSString *)fileName {
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@_blurred.jpg",fileName]];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    return  [fileMgr fileExistsAtPath:jpgPath];
}

+ (UIImage *)getBlurredImage:(NSString *)fileName {
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@_blurred.jpg",fileName]];

    UIImage *image = [UIImage imageNamed:fileName];

    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];

    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);

    return  [UIImage imageWithContentsOfFile:jpgPath];
}


@end