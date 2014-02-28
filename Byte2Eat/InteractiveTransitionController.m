//
//  InteractiveTransitionController.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 27/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "InteractiveTransitionController.h"
#import "OrderHistoryViewController.h"

@implementation InteractiveTransitionController{
    BOOL _shouldCompleteTransition;
    UIViewController *toViewController;
    UIPanGestureRecognizer *panGesture;
}

-(void)prepareTransitionController:(UIViewController *)viewController{
    NSLog(@"Gesture recognizer added");
    toViewController = viewController;
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [toViewController.view addGestureRecognizer:panGesture];
}

-(void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer{
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"Gesture began");
            self.interactionInProgress = YES;
            [toViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGFloat y = MIN(0, -translation.y);
            NSLog(@"Gesture changed Y : %f",y);
            if (self.interactionInProgress) {
                if (-y > 240) {
                    _shouldCompleteTransition = YES;
                }
                //        CGFloat angle = M_PI_2*(y/160);
                //        topHalfSnapshot.layer.transform = CATransform3DRotate(transform, angle, 1, 0, 0);
                [self updateInteractiveTransition:-y/310];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSLog(@"Gesture Cancelled");
            if (self.interactionInProgress) {
                NSLog(@"Interaction in progress");
                self.interactionInProgress = NO;
                if (!_shouldCompleteTransition) {
                    NSLog(@"Transition Cancelled");
                    [self cancelInteractiveTransition];
                }
                else {
                    NSLog(@"Transition finished");
                    [self finishInteractiveTransition];
                }
            }
            break;
        }
        default:
            break;
    }
}

@end
