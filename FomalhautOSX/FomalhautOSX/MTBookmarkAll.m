//
//  MTBookmarkAll.m
//  FomalhautOSX
//
//  Created by User on 1/8/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTBookmarkAll.h"

@implementation MTBookmarkAll

+ (MTBookmarkAll *)sharedInstance {
    static MTBookmarkAll *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (NSString *)displayName {
    return @"All";
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithValue:YES];
}

@end
