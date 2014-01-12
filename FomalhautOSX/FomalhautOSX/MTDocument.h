//
//  MTDocument.h
//  FomalhautOSX
//
//  Created by User on 12/29/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

@import Cocoa;

@interface MTDocument : NSDocument

/**
 * retrieve the sorted array of MTPage instances.
 */
- (NSArray *)getPages;

- (NSUInteger)numberOfPages;

- (NSData *)dataOfIndex:(NSUInteger)index;

- (NSData *)dataOfIndex:(NSUInteger)index withSize:(CGSize)size;

@end
