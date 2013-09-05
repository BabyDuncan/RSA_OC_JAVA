//
//  AsFirstTest.m
//  saccounts_ios_sdk_sso_framework
//
//  Created by BabyDuncan on 13-9-4.
//  Copyright (c) 2013年 SOHU.COM. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@interface AsFirstTest : GHAsyncTestCase{}

@end

@implementation AsFirstTest

-(void) testAs;{
    [self prepare];
    __block NSString * result = @"";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", operation.responseString);
        result = operation.responseString;
        [self notify:kGHUnitWaitStatusSuccess];
        NSLog(@"result is %@", result);
    }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
    }];
    [operation start];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    
}

@end
