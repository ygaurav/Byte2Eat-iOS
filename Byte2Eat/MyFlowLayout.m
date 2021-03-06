#import "MyFlowLayout.h"

CGFloat ACTIVE_DISTANCE = 275;
CGFloat RADIUS = 300;

@implementation MyFlowLayout

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
                angle = (CGFloat) asin(-distanceInX/ RADIUS);
                attr.transform3D = CATransform3DMakeRotation(angle, 0, 0, 1);
            }
            CGFloat d = MAX(0 , 1 - ABS(distanceInX/200));
            attr.alpha = d;
//            attr.transform3D = CATransform3DScale(attr.transform3D, d, d, d);
            CGFloat y = (CGFloat) (attr.center.y + RADIUS *(1 - cos(angle)));
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
