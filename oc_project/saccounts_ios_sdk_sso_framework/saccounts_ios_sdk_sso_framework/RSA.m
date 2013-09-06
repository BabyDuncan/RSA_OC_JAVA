//
//  RSA.m
//  saccounts_ios_sdk_sso_framework
//
//  Created by BabyDuncan on 13-9-5.
//  Copyright (c) 2013年 SOHU.COM. All rights reserved.
//

#import "RSA.h"
#import "Base64.h"

@implementation RSA

- (NSString *)encryptRSA:(NSString *)plainTextString {
    SecKeyRef publicKey = [self getPublicKey];
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    uint8_t *nonce = (uint8_t *) [plainTextString UTF8String];
    SecKeyEncrypt(publicKey,
            kSecPaddingPKCS1,
            nonce,
            strlen((char *) nonce),
            &cipherBuffer[0],
            &cipherBufferSize);
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    return [encryptedData base64EncodedString];
}


- (NSString *)decryptRSA:(NSString *)cipherString key:(SecKeyRef)privateKey {
    size_t plainBufferSize = SecKeyGetBlockSize(privateKey);
    uint8_t *plainBuffer = malloc(plainBufferSize);
    NSData *incomingData = [NSData dataWithBase64EncodedString:cipherString];
    uint8_t *cipherBuffer = (uint8_t *) [incomingData bytes];
    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    SecKeyDecrypt(privateKey,
            kSecPaddingPKCS1,
            cipherBuffer,
            cipherBufferSize,
            plainBuffer,
            &plainBufferSize);
    NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return decryptedString;
}

- (SecKeyRef)getPublicKey {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    SecCertificateRef myCertificate = nil;
    NSData *certificateData = [[NSData alloc] initWithContentsOfFile:resourcePath];
    myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge_retained CFDataRef) certificateData);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate, myPolicy, &myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    return SecTrustCopyPublicKey(myTrust);

}


@end
