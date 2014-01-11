//
//  NSArray+Function.m
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "NSArray+Function.h"

@implementation NSArray (Function)

- (NSArray *)mapWithBlocks:(id(^)(id obj))block {
    if (![self count]) {
        return self;
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj)];
    }];
    return result;
}

- (NSArray *)withFilterBlock:(BOOL(^)(id obj))filterBlock mapBlock:(id(^)(id obj))mapBlock {
    if (![self count]) {
        return self;
    }
    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (filterBlock(obj)) {
            [result addObject:mapBlock(obj)];
        }
    }];
    return result;
}
@end
