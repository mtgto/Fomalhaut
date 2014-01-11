//
//  MTZipEntryPage.m
//  FomalhautOSX
//
//  Created by User on 1/11/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTZipEntryPage.h"

@interface MTZipEntryPage()

@property (nonatomic, strong) ZZArchiveEntry *entry;

@end

@implementation MTZipEntryPage

- (id)initWithZipEntry:(ZZArchiveEntry *)entry {
    if (self = [super init]) {
        self.entry = entry;
    }
    return self;
}

- (NSString *)fileName {
    return [self.entry fileName];
}

- (NSData *)data {
    return [self.entry data];
}

- (NSImage *)image {
    return [[NSImage alloc] initWithData:[self.entry data]];
}

@end
