//
//  MyWideCollectionViewCell.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 19/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWideCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelItemName;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *labelQuantity;
@property (weak, nonatomic) IBOutlet UILabel *labelItemPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelItemCost;

@end
