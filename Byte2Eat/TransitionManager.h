//
//  TransitionManager.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 08/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>

//Define a custom type for the transition mode
//It simply says which is the current showed view...
typedef NS_ENUM(NSUInteger, TransitionStep){
    INITIAL = 0,
    MODAL
};

typedef NS_ENUM(NSInteger, SOLEdge) {
    SOLEdgeTop,
    SOLEdgeLeft,
    SOLEdgeBottom,
    SOLEdgeRight,
    SOLEdgeTopRight,
    SOLEdgeTopLeft,
    SOLEdgeBottomRight,
    SOLEdgeBottomLeft
};

@interface TransitionManager : NSObject <UIViewControllerAnimatedTransitioning>

@property(nonatomic) BOOL transitionTo;
@property (nonatomic, assign) CGFloat dampingRatio;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign, getter = isAppearing) BOOL appearing;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) SOLEdge edge;
- (CGRect)rectOffsetFromRect:(CGRect)rect atEdge:(SOLEdge)edge;


@end
