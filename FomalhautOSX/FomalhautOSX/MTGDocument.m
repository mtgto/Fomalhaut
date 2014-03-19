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

#import "MTGDocument.h"
#import <zipzap/zipzap.h>
#import "NSArray+Function.h"
#import "MTGBookWindowController.h"
#import "MTGZipEntryPage.h"
#import "NSImage+Resize.h"

@implementation MTGDocument

- (void)makeWindowControllers
{
    MTGBookWindowController *windowController = [[MTGBookWindowController alloc] initWithWindowNibName:@"MTGBookWindowController"];
    [self addWindowController:windowController];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSArray *)getPages {
    DDLogError(@"You need to implement - (NSArray *)getPages");
    return nil;
}

#pragma -

- (NSUInteger)numberOfPages {
    DDLogError(@"You need to implement - (NSUInteger)numberOfPages");
    return 0;
}

- (NSData *)dataOfIndex:(NSUInteger)index {
    DDLogError(@"You need to implement - (NSData *)dataOfIndex:(NSUInteger)index");
    return nil;
}

- (NSData *)dataOfIndex:(NSUInteger)index withSize:(CGSize)size {
    NSImage *image = [[self getPages][index] image];
    if (image) {
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[[image resizeKeepAspectWithSize:size] TIFFRepresentation]];
        return [rep representationUsingType:NSJPEGFileType properties:nil];
    }
    return nil;
}

@end
