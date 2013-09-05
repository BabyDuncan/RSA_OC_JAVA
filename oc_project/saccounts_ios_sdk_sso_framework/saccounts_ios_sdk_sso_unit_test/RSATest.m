//
//  RSATest.m
//  saccounts_ios_sdk_sso_framework
//
//  Created by BabyDuncan on 13-9-5.
//  Copyright (c) 2013年 SOHU.COM. All rights reserved.
//

#import <GHUnitIOS/GHTestCase.h>
#import "RSA.h"

@interface RSATest : GHTestCase {
}
@end

@implementation RSATest

- (void)testRSA {
    NSString *s = @"BabyDuncan";
    RSA *rsa = [RSA new];
    NSString *result = [rsa encryptRSA:s];
    NSLog(@"result is %@", result);
}

@end
