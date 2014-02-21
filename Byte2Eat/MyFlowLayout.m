//
//  MyFlowLayout.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 19/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "MyFlowLayout.h"

CGFloat ACTIVE_DISTANCE = 275;
CGFloat RADIUS = 300;

@implementation MyFlowLayout

#pragma Springy Layout
//-(void)prepareLayout {
//    [super prepareLayout];
//
//    if(!_dynamicAnimator){
//        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];

//        CGSize contentSize = [self collectionViewContentSize];
//        NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
//
//        for(UICollectionViewLayoutAttributes *item in items){
//            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:[item center]];
//            spring.length = 0;
//            spring.damping = 0.5;
//            spring.frequency = 0.8;
//            [_dynamicAnimator addBehavior:spring];
//        }
//    }
//}
//
//-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    return [_dynamicAnimator itemsInRect:rect];
//}
//
//-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return [_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
//}
//
//-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    UIScrollView *scrollView = self.collectionView;
//    CGFloat  scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
//
//    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
//
//    for(UIAttachmentBehavior *spring in _dynamicAnimator.behaviors){
//        CGPoint anchorPoint = spring.anchorPoint;
//        CGFloat  distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
//
//        CGFloat  scrollResistance = distanceFromTouch/ 500;
//
//        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
//        CGPoint center = item.center;
//        center.y += MIN(scrollDelta, scrollDelta * scrollResistance);
//        item.center = center;
//
//        [_dynamicAnimator updateItemUsingCurrentState:item];
//    }
//
//    return NO;
//}

//-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    NSMutableArray* attributes = [NSMutableArray array];
//    for (NSInteger i=0 ; i < _cellCount; i++) {
//        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
//    }
//    return attributes;
//}
//
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
//{
//    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
//    attributes.alpha = 1;
//    return attributes;
//}

#pragma Simple insertion deletion animation
//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    if ([self.insertIndexPaths containsObject:itemIndexPath]) {
//        if (!attributes)
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//
//        attributes.center = CGPointMake(attributes.center.x, attributes.center.y + 100);
//        attributes.alpha = 0;
//    }
//    return attributes;
//}
//
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
//
//    if ([self.deleteIndexPaths containsObject:itemIndexPath]){
//        if (!attributes)
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        attributes.alpha = 0.0;
//        attributes.center = CGPointMake(attributes.center.x, attributes.center.y - 100);
//    }
//    return attributes;
//}
//
//- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
//    [super prepareForCollectionViewUpdates:updateItems];
//
//    self.deleteIndexPaths = [NSMutableArray array];
//    self.insertIndexPaths = [NSMutableArray array];
//
//    for (UICollectionViewUpdateItem *update in updateItems)
//    {
//        if (update.updateAction == UICollectionUpdateActionDelete)
//        {
//            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
//        }
//        else if (update.updateAction == UICollectionUpdateActionInsert)
//        {
//            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
//        }
//    }
//}
//
//- (void)finalizeCollectionViewUpdates {
//    [super finalizeCollectionViewUpdates];
//    self.deleteIndexPaths = nil;
//    self.insertIndexPaths = nil;
//}

#pragma  Paper like Circular layout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    for (UICollectionViewLayoutAttributes *attr in array) {
        CGFloat distanceInX = CGRectGetMidX(visibleRect) - attr.center.x;
        CGFloat angle = 0;
        if (CGRectIntersectsRect(attr.frame, rect)) {
            if (ABS(distanceInX) < ACTIVE_DISTANCE) {
                angle = (CGFloat) asin(-distanceInX/RADIUS);
                attr.transform3D = CATransform3DMakeRotation(angle, 0, 0, 1);
            }
            attr.alpha = MAX(0 , 1 - ABS(distanceInX/200));
            CGFloat y = (CGFloat) (attr.center.y + RADIUS*(1 - cos(angle)));
            attr.center = CGPointMake(attr.center.x, y);
        }
    }
    return array;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds)/2);
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];

    for(UICollectionViewLayoutAttributes *attributes in array){
        CGFloat itemHorizontalCenter = attributes.center.x;
        if(ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)){
            offsetAdjustment = itemHorizontalCenter- horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y) ;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
