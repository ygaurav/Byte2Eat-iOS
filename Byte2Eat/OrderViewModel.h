//
// Created by Gaurav Yadav on 17/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OrderViewModel : NSObject

@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) NSDate *orderDate;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *displayOrder;

@end