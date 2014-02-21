//
//  MyFlowLayout.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 19/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic, assign) NSInteger cellCount;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@end
