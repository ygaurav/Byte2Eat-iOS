//
//  MyFlowLayout.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 19/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "MyFlowLayout.h"

@implementation MyFlowLayout{
    UIDynamicAnimator *_dynamicAnimator;
}

-(void)prepareLayout {
    [super prepareLayout];

    if(!_dynamicAnimator){
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];

        CGSize contentSize = [self collectionViewContentSize];
        NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];

        for(UICollectionViewLayoutAttributes *item in items){
            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:[item center]];
            spring.length = 0;
            spring.damping = 0.5;
            spring.frequency = 0.8;
            [_dynamicAnimator addBehavior:spring];
        }
    }
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [_dynamicAnimator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    UIScrollView *scrollView = self.collectionView;
    CGFloat  scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;

    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];

    for(UIAttachmentBehavior *spring in _dynamicAnimator.behaviors){
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat  distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);

        CGFloat  scrollResistance = distanceFromTouch/ 500;

        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
        CGPoint center = item.center;
        center.y += MIN(scrollDelta, scrollDelta * scrollResistance);
        item.center = center;

        [_dynamicAnimator updateItemUsingCurrentState:item];
    }

    return NO;
}

@end
