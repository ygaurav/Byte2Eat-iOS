//
// Created by Gaurav Yadav on 09/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "Constants.h"


@implementation Constants

NSString *const keyUserId = @"UserId";
NSString *const keyUserName = @"UserName";
NSString *const keyBalance = @"Balance";
NSString *const keyTodaysOrderQty = @"TodaysOrderQty";
NSString *const keyResponseMessage = @"ResponseMessage";
NSString *const keyMenuId = @"Id";
NSString *const keyItemName = @"ItemName";
NSString *const keyItemPrice = @"ItemPrice";
NSString *const keyOrderHistory = @"OrderHistory";
NSString *const keyBoolValue = @"BoolValue";

int const keyAlertOrderConfirm = 1;
int const keyErrorMessageTime = 3;

NSString *const keyURLUserAuth = @"http://10.37.1.148:70/api/esms/user/%@";
NSString *const keyURLDailyMenu = @"http://10.37.1.148:70/api/esms/menu";
NSString *const keyURLOrderHistory = @"http://10.37.1.148:70/api/esms/orders/%@";
NSString *const keyURLPostOrder = @"http://10.37.1.148:70/api/esms/order";

@end