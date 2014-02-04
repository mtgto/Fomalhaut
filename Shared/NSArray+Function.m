/*
 Fomalhaut
 Copyright (C) 2014 mtgto

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
