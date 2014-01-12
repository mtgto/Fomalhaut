//
//  NSImage+Resize.m
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "NSImage+Resize.h"

@implementation NSImage (Resize)

- (NSImage *)resize:(CGSize)size {
    NSImage *image = [[NSImage alloc] initWithSize:size];

    NSSize  oldSize = [self size];
    NSRect  sourceRect = NSMakeRect(0, 0, oldSize.width, oldSize.height);
    NSRect  destRect = NSMakeRect(0, 0, size.width, size.height);

    [image lockFocus];
    [self drawInRect:destRect fromRect:sourceRect operation:NSCompositeCopy fraction:1.0];
    [image unlockFocus];

    return image;
}

- (NSImage *)resizeKeepAspectWithSize:(CGSize)size {
    CGSize oldSize = [self size];
    float ratio = fminf(size.width / oldSize.width, size.height / oldSize.height);
    NSSize newSize;
    newSize.width = oldSize.width * ratio;
    newSize.height = oldSize.height * ratio;
    return [self resize:newSize];
}

@end
