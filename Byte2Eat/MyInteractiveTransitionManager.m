#import "MyInteractiveTransitionManager.h"

@implementation MyInteractiveTransitionManager {
    CGPoint touchCenter;
    CGRect initialFrame;
    UIView *toViewTopHalfSnapshot;
    UIView *toViewBottomHalfSnapshot;
    UIView *toViewFullSnapShot ;
    UIView *fromViewFullSnapShot;
    UIView *fromViewTopHalfSnapshot;
    UIView *fromViewBottomHalfSnapshot;
    CATransform3D transform;
    CATransform3D fromTransform;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    UIView* containerView = [transitionContext containerView];
    initialFrame = containerView.frame;
    
    NSLog(@"Animating transition");
    
    toView.frame = CGRectOffset(toView.frame, toView.frame.size.width, 0);
    [containerView addSubview:toView];
    
    fromView.frame = CGRectOffset(fromView.frame, fromView.frame.size.width, 0);
    
    toViewFullSnapShot = [toView snapshotViewAfterScreenUpdates:YES];
    fromViewFullSnapShot = [fromView snapshotViewAfterScreenUpdates:NO];
    
    CGRect topHalfRect = CGRectMake(CGRectGetMinX(initialFrame),
                                    CGRectGetMinY(initialFrame),
                                    CGRectGetWidth(initialFrame),
                                    CGRectGetHeight(initialFrame) / 2.0);
    
    CGRect bottomHalfRect = CGRectMake(CGRectGetMinX(initialFrame),
                                       CGRectGetMidY(initialFrame),
                                       CGRectGetWidth(initialFrame),
                                       CGRectGetHeight(initialFrame) / 2.0);
    
    toViewTopHalfSnapshot = [toViewFullSnapShot resizableSnapshotViewFromRect:topHalfRect
                                               afterScreenUpdates:YES
                                                    withCapInsets:UIEdgeInsetsZero];
    
    toViewBottomHalfSnapshot = [toViewFullSnapShot resizableSnapshotViewFromRect:bottomHalfRect
                                                  afterScreenUpdates:YES
                                                       withCapInsets:UIEdgeInsetsZero];

    fromViewTopHalfSnapshot = [fromViewFullSnapShot resizableSnapshotViewFromRect:topHalfRect
                                                           afterScreenUpdates:YES
                                                                withCapInsets:UIEdgeInsetsZero];
    
    fromViewBottomHalfSnapshot = [fromViewFullSnapShot resizableSnapshotViewFromRect:bottomHalfRect
                                                              afterScreenUpdates:YES
                                                                   withCapInsets:UIEdgeInsetsZero];
    

    
//    [containerView addSubview:toViewBottomHalfSnapshot];
//    toViewBottomHalfSnapshot.center = CGPointMake(toViewBottomHalfSnapshot.center.x, toViewBottomHalfSnapshot.center.y + toViewBottomHalfSnapshot.bounds.size.height);
//    [containerView addSubview:toViewTopHalfSnapshot];
//    
//    [containerView addSubview:fromViewTopHalfSnapshot];
//    fromViewBottomHalfSnapshot.center = CGPointMake(fromViewBottomHalfSnapshot.center.x, fromViewBottomHalfSnapshot.center.y + fromViewBottomHalfSnapshot.bounds.size.height);
//    [containerView addSubview:fromViewBottomHalfSnapshot];
//    
//    toViewTopHalfSnapshot.layer.anchorPoint = CGPointMake(0.5, 1);
//    toViewTopHalfSnapshot.layer.position = [self getLayerPosition:toViewTopHalfSnapshot.layer];
//    
//    fromViewBottomHalfSnapshot.layer.anchorPoint = CGPointMake(0.5, 0);
//    fromViewBottomHalfSnapshot.layer.position = CGPointMake(fromViewBottomHalfSnapshot.layer.position.x, fromViewBottomHalfSnapshot.layer.position.y + fromViewBottomHalfSnapshot.layer.bounds.size.height/2);
    
    // FROM TOP HALF
    [containerView addSubview:fromViewTopHalfSnapshot];
    NSLog(@"from top %f,%f",fromViewTopHalfSnapshot.center.x,fromViewTopHalfSnapshot.center.y);
    
    //TO BOTTOM HALF
    toViewBottomHalfSnapshot.center = CGPointMake(toViewBottomHalfSnapshot.center.x, toViewBottomHalfSnapshot.center.y + toViewBottomHalfSnapshot.bounds.size.height);
//    [containerView addSubview:toViewBottomHalfSnapshot];
    NSLog(@"to bottom %f,%f",toViewBottomHalfSnapshot.center.x,toViewBottomHalfSnapshot.center.y);
    
    // TO TOP HALF
    toViewTopHalfSnapshot.layer.anchorPoint = CGPointMake(0.5, 1);
    toViewTopHalfSnapshot.layer.position = [self getLayerPosition:toViewTopHalfSnapshot.layer];
    [containerView addSubview:toViewTopHalfSnapshot];
    toViewTopHalfSnapshot.layer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    NSLog(@"to top%f,%f",toViewTopHalfSnapshot.center.x,toViewTopHalfSnapshot.center.y);
    
    //FROM BOTTOM HALF
    fromViewBottomHalfSnapshot.layer.anchorPoint = CGPointMake(0.5, 0);
    fromViewBottomHalfSnapshot.layer.position = CGPointMake(fromViewBottomHalfSnapshot.layer.position.x, fromViewBottomHalfSnapshot.layer.position.y + fromViewBottomHalfSnapshot.layer.bounds.size.height/2);
//    [containerView addSubview:fromViewBottomHalfSnapshot];
    [containerView insertSubview:fromViewBottomHalfSnapshot aboveSubview:toViewTopHalfSnapshot];

     NSLog(@"from bottom%f,%f",fromViewBottomHalfSnapshot.center.x,fromViewBottomHalfSnapshot.center.y);
    
    transform = CATransform3DIdentity;
    transform.m34 = 1.0/-1000;
    
    fromTransform = CATransform3DIdentity;
    fromTransform.m34 = 1.0/-1000;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         toViewTopHalfSnapshot.layer.transform = CATransform3DRotate(transform, -M_PI*(160/180), 1, 0, 0);  
                         fromViewBottomHalfSnapshot.layer.transform = CATransform3DRotate(fromTransform, M_PI_2*(1.95), 1, 0, 0);
//                         fromViewTopHalfSnapshot.layer.transform = CATransform3DRotate(fromTransform, M_PI*(160/180), 1, 0, 0);
                     }
                     completion:^(BOOL finished){
                         [fromViewTopHalfSnapshot removeFromSuperview];
                         [fromViewBottomHalfSnapshot removeFromSuperview];
                         [toViewTopHalfSnapshot removeFromSuperview];
                         [toViewBottomHalfSnapshot removeFromSuperview];
                         
                         toView.frame = containerView.bounds;
                         fromView.frame = containerView.bounds;
                         NSLog(@"Transition : %d",[transitionContext transitionWasCancelled]);
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
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
@end
