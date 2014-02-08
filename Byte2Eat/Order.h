//
// Created by Gaurav Yadav on 09/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Order : NSObject
@property (strong, nonatomic) NSNumber *Quantity;
@property (strong, nonatomic) NSNumber *DailyMenuId;
@property (strong, nonatomic) NSNumber *UserId;
@property (strong, nonatomic) NSDate *orderDate;
@property (strong, nonatomic) NSString *ItemName;
@property (strong, nonatomic) NSString *DeviceInfo;
@property (strong, nonatomic) NSNumber *Cost;
@property (strong, nonatomic) NSNumber *Price;
@end