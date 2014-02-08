//
//  TransitionManager.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "TransitionManager.h"

@implementation TransitionManager

static CGFloat const kDefaultDampingRatio = 0.5;
static CGFloat const kDefaultVelocity = 4.0;

- (id)init
{
    self = [super init];
    if (self) {
        _dampingRatio = kDefaultDampingRatio;
        _velocity = kDefaultVelocity;
        _edge = SOLEdgeTop;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning -

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1.2;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    CGFloat duration = [self transitionDuration:transitionContext];

    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect offscreenRect = [self rectOffsetFromRect:initialFrame atEdge:self.edge];

    // Presenting
    if (self.appearing) {
        // Position the view offscreen
        toView.frame = offscreenRect;
        [containerView addSubview:toView];

        // Animate the view onscreen
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:self.dampingRatio
              initialSpringVelocity:self.velocity
                            options:0
                         animations: ^{
                             toView.frame = initialFrame;
                         } completion: ^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
            // Dismissing
    else {
        [containerView addSubview:toView];
        [containerView sendSubviewToBack:toView];

        // Animate the view offscreen
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:self.dampingRatio
              initialSpringVelocity:self.velocity
                            options:0
                         animations: ^{
                             fromView.frame = offscreenRect;
                         } completion: ^(BOOL finished) {
            [fromView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

- (CGRect)rectOffsetFromRect:(CGRect)rect atEdge:(SOLEdge)edge
{
    CGRect offsetRect = rect;

    switch (edge) {
        case SOLEdgeTop: {
            offsetRect.origin.y -= CGRectGetHeight(rect);
            break;
        }
        case SOLEdgeLeft: {
            offsetRect.origin.x -= CGRectGetWidth(rect);
            break;
        }
        case SOLEdgeBottom: {
            offsetRect.origin.y += CGRectGetHeight(rect);
            break;
        }
        case SOLEdgeRight: {
            offsetRect.origin.x += CGRectGetWidth(rect);
            break;
        }
        case SOLEdgeTopRight: {
            offsetRect.origin.y -= CGRectGetHeight(rect);
            offsetRect.origin.x += CGRectGetWidth(rect);
            break;
        }
        case SOLEdgeTopLeft: {
            offsetRect.origin.y -= CGRectGetHeight(rect);
            offsetRect.origin.x -= CGRectGetWidth(rect);
            break;
        }
        case SOLEdgeBottomRight: {
            offsetRect.origin.y += CGRectGetHeight(rect);
            offsetRect.origin.x += CGRectGetWidth(rect);
            break;
        }
        case SOLEdgeBottomLeft: {
            offsetRect.origin.y += CGRectGetHeight(rect);
            offsetRect.origin.x -= CGRectGetWidth(rect);
            break;
        }
        default:
            break;
    }

    return offsetRect;
}

@end

