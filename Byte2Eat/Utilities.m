//
// Created by Gaurav Yadav on 16/02/14.
// Copyright (c) 2014 spiderlogic. All rights reserved.
//

@import CoreData;
#import "Utilities.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Order.h"


@implementation Utilities

+ (BOOL)isUserLoggedIn {

    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
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
        NSLog(@"Error reading plist: %@, format: %u", errorDesc, format);
    }
    NSString *personName = temp[@"UserName"];
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

    NSString *userName = dictionary[keyUserName];
    NSString *balance = dictionary[keyBalance];
    NSString *userId = dictionary[keyUserId];
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"UserDetail.plist"];
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserDetail" ofType:@"plist"];
    NSDictionary *plistDict = @{keyUserName: userName,keyBalance: balance,keyUserId: userId};

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
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
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
        NSLog(@"Error reading plist: %@, format: %u", errorDesc, format);
    }
    return temp;
}

+ (NSManagedObjectContext *)getManagedObjectContext {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}

+ (void) logUserOut{
    NSString *error;

    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"UserDetail.plist"];

    NSDictionary *plistDict = @{keyUserName: @"",keyBalance: @"",keyUserId: @""};

    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        BOOL b = [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Did logout save file : %d", b);
        NSManagedObjectContext *managedObjectContext = [Utilities getManagedObjectContext];
        [managedObjectContext deletedObjects];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedRecords = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

        if(error){
            NSLog(@"Error fetching order data on log out");
        }
        if (fetchedRecords.count > 0) {
            for (Order *order in fetchedRecords) {
                [managedObjectContext deleteObject:order];
            }
            [managedObjectContext save:&error];
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            }
        }
    }
    else {
        NSLog(@"Something happened while logging out saving username in plist");
    }
}

+(UIStoryboard *)getStoryBoard{
    UIStoryboard *storyboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil];
    }else{
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    return storyboard;
}

+(BOOL)isiPad{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

@end