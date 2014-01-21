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

#import "NSImage+Resize.h"

@implementation NSImage (Resize)

- (NSImage *)resize:(CGSize)size {
    NSImage *image = [[NSImage alloc] initWithSize:size];

    NSSize oldSize = [self size];
    NSRect sourceRect = NSMakeRect(0, 0, oldSize.width, oldSize.height);
    NSRect destRect = NSMakeRect(0, 0, size.width, size.height);

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
