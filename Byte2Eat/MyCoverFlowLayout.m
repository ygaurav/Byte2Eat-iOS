//
// Created by Gaurav Yadav on 21/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "MyCoverFlowLayout.h"


@implementation MyCoverFlowLayout
CGFloat ACTIVE_DISTANCE_COVER_FLOW = 275;
CGFloat RADIUS_COVER_FLOW = 300;

#pragma  Cover Flow Layout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    for (UICollectionViewLayoutAttributes *attr in array) {
        CGFloat distanceInX = CGRectGetMidX(visibleRect) - attr.center.x;
        CGFloat angle = 0;
        if (CGRectIntersectsRect(attr.frame, rect)) {
            if (ABS(distanceInX) < ACTIVE_DISTANCE_COVER_FLOW) {
                CATransform3D transform = CATransform3DIdentity;
                angle = (CGFloat) asin(distanceInX/ RADIUS_COVER_FLOW);
                transform.m34 = 1.0/-600;
                attr.transform3D = CATransform3DRotate(transform, angle, 0, 1, 0);
            }
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