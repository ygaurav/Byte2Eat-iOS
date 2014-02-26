#import <Foundation/Foundation.h>
#import "OrderViewController.h"
#import "OrderHistoryViewController.h"

@interface InteractiveTransitionManager : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property(nonatomic, strong) OrderHistoryViewController *orderHistoryController;
@property (nonatomic, assign) float scaleFactor;
@property (nonatomic, assign, getter = isAppearing) BOOL appearing;
@property (nonatomic, assign) CGFloat cornerRadius;

@end
