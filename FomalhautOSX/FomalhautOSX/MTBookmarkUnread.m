//
//  MTBookmarkUnread.m
//  FomalhautOSX
//
//  Created by User on 1/8/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTBookmarkUnread.h"

@implementation MTBookmarkUnread

+ (MTBookmarkUnread *)sharedInstance {
    static MTBookmarkUnread *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (NSString *)displayName {
    return @"Unread";
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"readCount = 0"];
}

@end
