//
//  MTDocument.m
//  FomalhautOSX
//
//  Created by User on 12/29/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTDocument.h"
#import <zipzap/zipzap.h>
#import "NSArray+Function.h"
#import "MTBookWindowController.h"
#import "MTZipEntryPage.h"
#import "NSImage+Resize.h"

@implementation MTDocument

- (void)makeWindowControllers
{
    MTBookWindowController *windowController = [[MTBookWindowController alloc] initWithWindowNibName:@"MTBookWindowController"];
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
