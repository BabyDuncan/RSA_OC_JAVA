//
//  FirstTest.m
//  saccounts_ios_sdk_sso_framework
//
//  Created by BabyDuncan on 13-9-3.
//  Copyright (c) 2013年 SOHU.COM. All rights reserved.
//


#import <GHUnitIOS/GHTestCase.h>

@interface FirstTest : GHTestCase {
}
@end

@implementation FirstTest

- (void)testStrings {
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);

    Hello *hello = [Hello new];
    [hello sayHello];
}

@end
