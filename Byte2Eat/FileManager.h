//
// Created by Gaurav Yadav on 16/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManager : NSObject

+(BOOL)doesBlurredImageExist:(NSString *)fileName;

+(UIImage *) getBlurredImage:(NSString *)fileName;

@end