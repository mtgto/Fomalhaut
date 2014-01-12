//
//  NSImage+Resize.h
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Resize)

- (NSImage *)resize:(CGSize)size;

- (NSImage *)resizeKeepAspectWithSize:(CGSize)size;

@end
