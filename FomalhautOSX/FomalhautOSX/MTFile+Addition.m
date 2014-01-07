//
//  MTFile+Addition.m
//  FomalhautOSX
//
//  Created by User on 1/5/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTFile+Addition.h"

@implementation MTFile (Addition)

- (void) awakeFromInsert {
    [super awakeFromInsert];
    self.uuid = [[NSUUID UUID] UUIDString];
    self.created = [NSDate timeIntervalSinceReferenceDate];
}

@end
