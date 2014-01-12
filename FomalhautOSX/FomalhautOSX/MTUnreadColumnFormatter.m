//
//  MTUnreadColumnFormatter.m
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTUnreadColumnFormatter.h"

@implementation MTUnreadColumnFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
    return [anObject intValue] == 0 ? @"●" : @"";
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes
{
    [attributes setValue:[NSColor greenColor] forKey:NSForegroundColorAttributeName];
    return [[NSAttributedString alloc] initWithString:[self stringForObjectValue:anObject] attributes:attributes];
}

@end
