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
