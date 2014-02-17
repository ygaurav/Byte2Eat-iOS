//
// Created by Gaurav Yadav on 16/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utilities : NSObject

+ (BOOL)isUserLoggedIn;

+ (void)setUserDetailsInPlist:(NSDictionary *)dictionary;

+ (void) logUserOut;

+ (NSDictionary *)getUserDetailsFromPlist;

@end