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
    CGFloat duration = [self transitionDuration:transitionContext];

    if (self.appearing) {
        fromView.userInteractionEnabled = NO;

        toView.layer.cornerRadius = 5;
        toView.layer.masksToBounds = YES;

        // Set initial scale to zero
        toView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        [containerView addSubview:toView];

        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:6
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                                toView.transform = CGAffineTransformMakeScale(self.scaleFactor, self.scaleFactor);
                                fromView.alpha = 0.5;
                         } completion:^(BOOL finished){
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]] ;
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
                            toView.alpha = 1.0;
                         } completion:^(BOOL finished){
            [fromView removeFromSuperview];
            toView.userInteractionEnabled = YES;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end

