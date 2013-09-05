//
// Created by BabyDuncan on 13-9-5.
// Copyright (c) 2013 SOHU.COM. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Base64.h"
#import <CommonCrypto/CommonDigest.h>

#import <Availability.h>

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

typedef enum {
    NSStringAuthCodeEncoded,
    NSStringAuthCodeDecoded
} NSStringAuthCode;


@implementation NSData (Base64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string {
    const char lookup[] =
            {
                    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
                    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
                    99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
                    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
                    99, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
                    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
                    99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
                    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
            };

    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];

    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *) [outputData mutableBytes];

    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++) {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99) {
            accumulated[accumulator] = decoded;
            if (accumulator == 3) {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }

    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;

    //truncate data to match actual output length
    outputData.length = outputLength;
    return outputLength ? outputData : nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth {
    //ensure wrapWidth is a multiple of 4
    wrapWidth = (wrapWidth / 4) * 4;

    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    long long inputLength = [self length];
    const unsigned char *inputBytes = [self bytes];

    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth ? (maxOutputLength / wrapWidth) * 2 : 0;
    unsigned char *outputBytes = (unsigned char *) malloc(maxOutputLength);

    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3) {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];

        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0) {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }

    //handle left-over data
    if (i == inputLength - 2) {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] = '=';
    }
    else if (i == inputLength - 1) {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }

    if (outputLength >= 4) {
        //truncate data to match actual output length
        outputBytes = realloc(outputBytes, outputLength);
        return [[NSString alloc] initWithBytesNoCopy:outputBytes
                                              length:outputLength
                                            encoding:NSASCIIStringEncoding
                                        freeWhenDone:YES];
    }
    else if (outputBytes) {
        free(outputBytes);
    }
    return nil;
}

- (NSString *)base64EncodedString {
    return [self base64EncodedStringWithWrapWidth:0];
}

@end


@implementation NSString (Base64)

+ (NSString *)stringWithBase64EncodedString:(NSString *)string encoding:(NSStringEncoding)encoding {
    NSData *data = [NSData dataWithBase64EncodedString:string];
    if (data) {
        return [[self alloc] initWithData:data encoding:encoding];
    }
    return nil;
}

+ (NSString *)stringWithBase64EncodedString:(NSString *)string {
    return [self stringWithBase64EncodedString:string encoding:NSUTF8StringEncoding];
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString:(NSStringEncoding)encoding {
    NSData *data = [self dataUsingEncoding:encoding allowLossyConversion:YES];
    return [data base64EncodedString];
}

- (NSString *)base64EncodedString {
    return [self base64EncodedString:NSUTF8StringEncoding];
}

- (NSString *)base64DecodedString:(NSStringEncoding)encoding {
    return [NSString stringWithBase64EncodedString:self encoding:encoding];
}

- (NSString *)base64DecodedString {
    return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData {
    return [NSData dataWithBase64EncodedString:self];
}

- (NSString *)md5 {
    const char *concat_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

- (NSString *)authCode:(NSString *)auth_key operation:(NSStringAuthCode)operation encoding:(NSStringEncoding)encoding; {
    NSMutableArray *rndkey = [NSMutableArray array];
    NSMutableArray *box = [NSMutableArray array];
    NSMutableString *result = [NSMutableString string];

    NSString *key = [auth_key md5];
    NSUInteger key_length = key.length;
    NSString *string = (operation == NSStringAuthCodeDecoded) ? [self base64DecodedString:encoding] : [NSString stringWithFormat:@"%@%@", [[[NSString stringWithFormat:@"%@%@", self, key] md5] substringToIndex:8], self];
    NSUInteger string_length = string.length;

    for (int i = 0; i <= 255; i++) {
        [rndkey addObject:[NSNumber numberWithUnsignedShort:[key characterAtIndex:i % key_length]]];
        [box addObject:[NSNumber numberWithUnsignedShort:i]];
    }

    int j = 0;
    for (int i = 0; i < 256; i++) {
        unsigned short b = [[box objectAtIndex:i] unsignedShortValue];
        unsigned short r = [[rndkey objectAtIndex:i] unsignedShortValue];
        j = (j + b + r) % 256;
        [box replaceObjectAtIndex:i withObject:[box objectAtIndex:j]];
        [box replaceObjectAtIndex:j withObject:[NSNumber numberWithUnsignedShort:b]];
    }

    int a = 0;
    j = 0;
    for (int i = 0; i < string_length; i++) {
        a = (a + 1) % 256;
        unsigned short b = [[box objectAtIndex:a] unsignedShortValue];
        j = (j + b) % 256;
        [box replaceObjectAtIndex:a withObject:[box objectAtIndex:j]];
        [box replaceObjectAtIndex:j withObject:[NSNumber numberWithUnsignedShort:b]];

        unsigned short sc = [string characterAtIndex:i];
        unsigned short bi = [[box objectAtIndex:(([[box objectAtIndex:a] unsignedShortValue] + [[box objectAtIndex:j] unsignedShortValue]) % 256)] unsignedShortValue];
        unsigned short k = sc ^ bi;
        [result appendFormat:@"%C", k];
    }

    if (operation == NSStringAuthCodeDecoded) {
        NSString *start = [result substringToIndex:8];
        NSString *end = [[[NSString stringWithFormat:@"%@%@", [result substringFromIndex:8], key] md5] substringToIndex:8];
        if ([start isEqualToString:end]) {
            return [result substringFromIndex:8];
        }
        else {
            return nil;
        }
    } else {
        return [[result base64EncodedString:encoding] stringByReplacingOccurrencesOfString:@"=" withString:@""];
    }
}

- (NSString *)authCodeEncoded:(NSString *)key encoding:(NSStringEncoding)encoding {
    return [self authCode:key operation:NSStringAuthCodeEncoded encoding:encoding];
}

- (NSString *)authCodeEncoded:(NSString *)key {
    return [self authCodeEncoded:key encoding:NSUTF8StringEncoding];
}

- (NSString *)authCodeDecoded:(NSString *)key encoding:(NSStringEncoding)encoding {
    return [self authCode:key operation:NSStringAuthCodeDecoded encoding:encoding];
}

- (NSString *)authCodeDecoded:(NSString *)key {
    return [self authCodeDecoded:key encoding:NSUTF8StringEncoding];
}

@end