#import <Foundation/Foundation.h>
#import "OrderViewController.h"
#import "OrderHistoryViewController.h"

@interface MyInteractiveTransitionManager : NSObject <UIViewControllerAnimatedTransitioning>

@property(nonatomic, assign) BOOL reverse;
@property(nonatomic, assign) NSTimeInterval duration;

@end
