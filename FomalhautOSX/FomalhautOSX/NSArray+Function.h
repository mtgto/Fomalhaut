//
//  NSArray+Function.h
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

@import Foundation;

@interface NSArray (Function)

- (NSArray *)mapWithBlocks:(id(^)(id obj, NSUInteger index))block;

@end