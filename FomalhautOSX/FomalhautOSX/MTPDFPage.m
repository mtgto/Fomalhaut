//
//  MTPDFPage.m
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTPDFPage.h"

@interface MTPDFPage()

@property (strong) PDFPage *pdfPage;

@end

@implementation MTPDFPage

- (id)initWithPDFPage:(PDFPage *)pdfPage {
    if (self = [super init]) {
        self.pdfPage = pdfPage;
    }
    return self;
}

- (NSString *)fileName {
    return nil;
}

- (NSData *)data {
    NSImage *image = [self image];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    return [rep representationUsingType:NSJPEGFileType properties:nil];
}

- (NSImage *)image {
    NSPDFImageRep *pdfImageRep = [NSPDFImageRep imageRepWithData:[self.pdfPage dataRepresentation]];
    NSSize size = [pdfImageRep size];

    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [pdfImageRep drawInRect: NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    return image;
}

@end
