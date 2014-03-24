//
//  Order.h
//  Byte2Eat
//
//  Created by Gaurav Yadav on 16/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Order : NSManagedObject

@property (nonatomic, retain) NSNumber *quantity;
@property (nonatomic, retain) NSDate *orderDate;
@property (nonatomic, retain) NSString *itemName;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSNumber *displayOrder;
@end
