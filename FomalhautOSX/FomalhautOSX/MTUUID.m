//
//  MTUUID.m
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTUUID.h"

@implementation MTUUID

+ (NSString *)generateUUID {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuidRef));
    CFRelease(uuidRef);
    return uuidString;
}

@end
