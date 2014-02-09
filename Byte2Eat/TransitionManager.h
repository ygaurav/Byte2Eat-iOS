//
//  TransitionManager.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TransitionManager : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isAppearing) BOOL appearing;
@property (nonatomic, assign) float scaleFactor;
@property (nonatomic, assign) NSTimeInterval duration;


@end
