//
//  TransitionManager.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "TransitionManager.h"

@implementation TransitionManager

#pragma mark - UIViewControllerAnimatedTransitioning -

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return .8;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    NSLog(@"Container view Frame : %f,%f -- %f,%f",containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.height, containerView.frame.size.width);
    NSLog(@"Container view bounds : %f,%f -- %f,%f",containerView.bounds.origin.x, containerView.bounds.origin.y, containerView.bounds.size.height, containerView.bounds.size.width);
    CGFloat duration = [self transitionDuration:transitionContext];

    if (self.appearing) {
        fromView.userInteractionEnabled = NO;
        toView.layer.cornerRadius = _cornerRadius;
        toView.layer.masksToBounds = YES;

        // Set initial scale to zero
        toView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        [containerView addSubview:toView];
        NSLog(@"Toview Frame : %f,%f -- %f,%f",toView.frame.origin.x, toView.frame.origin.y, toView.frame.size.height, toView.frame.size.width);
        NSLog(@"Toview Bounds : %f,%f -- %f,%f",toView.bounds.origin.x, toView.bounds.origin.y, toView.bounds.size.height, toView.bounds.size.width);

        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:6
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                                toView.transform = CGAffineTransformMakeScale(self.scaleFactor, self.scaleFactor);
                         } completion:^(BOOL finished){
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]] ;
            NSLog(@"Toview after completion Frame : %f,%f -- %f,%f",toView.frame.origin.x, toView.frame.origin.y, toView.frame.size.height, toView.frame.size.width);
            NSLog(@"Toview after completion Bounds : %f,%f -- %f,%f",toView.bounds.origin.x, toView.bounds.origin.y, toView.bounds.size.height, toView.bounds.size.width);
        }];
    }
    else {
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:8
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                         } completion:^(BOOL finished){
            [fromView removeFromSuperview];
            toView.userInteractionEnabled = YES;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end

