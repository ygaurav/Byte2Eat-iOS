#import "InteractiveTransitionManager.h"

@implementation InteractiveTransitionManager{
    CGPoint touchCenter;
    CGRect initialFrame;
    UIView *topHalfSnapshot;
    UIView *bottomHalfSnapshot;
    UIView *fullSnapShot ;
    CATransform3D transform;
}

-(CGPoint)getLayerPosition:(CALayer *)layer{
    CGFloat ax = layer.anchorPoint.x;
    CGFloat ay = layer.anchorPoint.y;
    CGPoint p = layer.position;
    CGFloat x,y;
    CGFloat width = layer.bounds.size.width;
    CGFloat height = layer.bounds.size.height;
    
    x = p.x - width*(.5 - ax);
    y = p.y + height*(ay - .5);
    
    return CGPointMake(x, y);
}

-(void)setMainController:(OrderHistoryViewController *)ohController{
    _orderHistoryController = ohController;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    [pan setMaximumNumberOfTouches:1];
    [pan setMinimumNumberOfTouches:1];
    [_orderHistoryController.historyTitleLabel addGestureRecognizer:pan];
}

- (void)gestureHandler:(UIPanGestureRecognizer*)panRecognizer{
    CGPoint touch = [panRecognizer translationInView:self.orderHistoryController.view];
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Began Gesture : %f , %f", touch.x, touch.y);
        fullSnapShot = [self.orderHistoryController.view snapshotViewAfterScreenUpdates:NO];
        
        CGRect topHalfRect = CGRectMake(CGRectGetMinX(initialFrame),
                                        CGRectGetMinY(initialFrame),
                                        CGRectGetWidth(initialFrame),
                                        CGRectGetHeight(initialFrame) / 2.0);
        
        topHalfSnapshot = [fullSnapShot resizableSnapshotViewFromRect:topHalfRect
                                                   afterScreenUpdates:NO
                                                        withCapInsets:UIEdgeInsetsZero];
        
        CGRect bottomHalfRect = CGRectMake(CGRectGetMinX(initialFrame),
                                           CGRectGetMidY(initialFrame),
                                           CGRectGetWidth(initialFrame),
                                           CGRectGetHeight(initialFrame) / 2.0);
        
        bottomHalfSnapshot = [fullSnapShot resizableSnapshotViewFromRect:bottomHalfRect
                                                      afterScreenUpdates:NO
                                                           withCapInsets:UIEdgeInsetsZero];
        
        //        [self.view addSubview:topHalfSnapshot];
        //        [self.view insertSubview:bottomHalfSnapshot belowSubview:topHalfSnapshot];
        
        topHalfSnapshot.layer.anchorPoint = CGPointMake(0.5, 1);
        topHalfSnapshot.layer.position = [self getLayerPosition:topHalfSnapshot.layer];
        transform.m34 = 1.0/-1000;
        
    }
    
    else if (panRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat y = MIN(0, -touch.y);
        //        CGFloat angle = M_PI_2*(y/160);
        //        topHalfSnapshot.layer.transform = CATransform3DRotate(transform, angle, 1, 0, 0);
        [self updateInteractiveTransition:y/310];
    }
    
    else if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Ended Gesture : %f , %f", touch.x, touch.y);
        
        //        [UIView animateWithDuration:0.5
        //                         animations:^{
        //                             topHalfSnapshot.layer.transform = CATransform3DIdentity;
        //                         } completion:^(BOOL finished){
        //                             [topHalfSnapshot removeFromSuperview];
        //                         }];
        //        [bottomHalfSnapshot removeFromSuperview];
        CGFloat y = MIN(0, -touch.y);
        if(y > 140){
            [self finishInteractiveTransition];
        }else{
            [self cancelInteractiveTransition];
        }
    }
    
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1.0;
}


//Define the transition
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    //STEP 1
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    CGFloat duration = [self transitionDuration:transitionContext];
    
    CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
    
    /*STEP 2:   Draw different transitions depending on the view to show
     for sake of clarity this code is divided in two different blocks
     */
    
    //STEP 2A: From the First View(INITIAL) -> to the Second View(MODAL)
    if(self.isAppearing){
        
        fromView.userInteractionEnabled = NO;
        toView.layer.cornerRadius = self.cornerRadius;
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
                         } completion:^(BOOL finished){
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]] ;
                         }];
    }
    
    //STEP 2B: From the Second view(MODAL) -> to the First View(INITIAL)
    else{
        
        [toView removeFromSuperview];
        [containerView addSubview:topHalfSnapshot];
        bottomHalfSnapshot.center = CGPointMake(bottomHalfSnapshot.center.x, bottomHalfSnapshot.center.y + bottomHalfSnapshot.bounds.size.height);
        [containerView addSubview:bottomHalfSnapshot];
        
        
        [UIView animateWithDuration:1
                         animations:^{
                             topHalfSnapshot.layer.transform = CATransform3DRotate(transform, -M_PI, 1, 0, 0);
                         } completion:^(BOOL finished){
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}

// Implement these 2 methods to perform interactive transitions
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return self; // We don't want to use interactive transition to dismiss the modal view, we are just going to use the standard animator.
}


@end
