//
//  InteractiveTransitionController.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 27/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InteractiveTransitionController : UIPercentDrivenInteractiveTransition

@property(nonatomic,assign) BOOL interactionInProgress;

-(void)prepareTransitionController:(UIViewController *)viewController;

@end
