//
// Created by Gaurav Yadav on 17/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OrderViewModel : NSObject

@property (nonatomic, weak) NSNumber *quantity;
@property (nonatomic, weak) NSDate *orderDate;
@property (nonatomic, weak) NSString *itemName;
@property (nonatomic, weak) NSNumber *price;
@property (nonatomic, weak) NSNumber *displayOrder;

@end