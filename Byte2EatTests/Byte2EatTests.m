//
//  Byte2EatTests.m
//  Byte2EatTests
//
//  Created by Gaurav Yadav on 07/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Byte2EatTests : XCTestCase

@end

@implementation Byte2EatTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)testFirstTest{
    XCTAssertTrue(true, @"It is true my friend");
}

- (void)testFirstFalse{
    XCTAssertNil(nil, @"It is nil my friend");
}

@end
