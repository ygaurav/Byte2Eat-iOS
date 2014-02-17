//
// Created by Gaurav Yadav on 16/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "Utilities.h"
#import "Constants.h"


@implementation Utilities

+ (BOOL)isUserLoggedIn {

    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"UserDetail.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"UserDetail" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
            propertyListFromData:plistXML
                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                          format:&format
                errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    NSString *personName = [temp objectForKey:@"UserName"];
    NSLog(@"User : %@", personName);

    if([personName isEqualToString:@""] || personName == nil){
        NSLog(@"User is not logged in");
        return NO;
    }
    NSLog(@"%@ is logged in.", personName);
    return YES;
}

+ (void)setUserDetailsInPlist:(NSDictionary *)dictionary {
    NSString *error;

    NSString *userName = [dictionary objectForKey:keyUserName];
    NSString *balance = [dictionary objectForKey:keyBalance];
    NSString *userId = [dictionary objectForKey:keyUserId];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"UserDetail.plist"];
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserDetail" ofType:@"plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: userName,balance,userId, nil]
                                                          forKeys:[NSArray arrayWithObjects: keyUserName,keyBalance,keyUserId, nil]];

    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        BOOL b = [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Did save file : %d", b);
    }
    else {
        NSLog(@"Something happened while saving username in plist");
    }
}

+ (NSDictionary *)getUserDetailsFromPlist {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"UserDetail.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"UserDetail" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
            propertyListFromData:plistXML
                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                          format:&format
                errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    return temp;
}

+ (void) logUserOut{
    NSString *error;

    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"UserDetail.plist"];

    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"",@"",@"", nil]
                                                          forKeys:[NSArray arrayWithObjects: keyUserName,keyBalance,keyUserId, nil]];

    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        BOOL b = [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Did logout save file : %d", b);
    }
    else {
        NSLog(@"Something happened while logging out saving username in plist");
    }
}

@end