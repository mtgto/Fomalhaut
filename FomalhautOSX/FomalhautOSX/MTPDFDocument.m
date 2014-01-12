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

#import "MTPDFDocument.h"
#import <Quartz/Quartz.h>
#import "MTPDFPage.h"

@interface MTPDFDocument()

@property (strong) PDFDocument *pdf;
@property (nonatomic, strong) NSArray *pages;

@end

@implementation MTPDFDocument

- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    self = [super initWithContentsOfURL:url ofType:typeName error:outError];
    if (self) {
        // Add your subclass-specific initialization here.
        self.pdf = [[PDFDocument alloc] initWithURL:url];
        [self setFileURL:url];
    }
    return self;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    return YES;
}

#pragma mark -

- (NSArray *)getPages {
    if (self.pages) {
        return self.pages;
    }
    NSUInteger count = [self.pdf pageCount];
    NSMutableArray *pages = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i=0; i<count; i++) {
        [pages addObject:[[MTPDFPage alloc] initWithPDFPage:[self.pdf pageAtIndex:i]]];
    }
    self.pages = pages;
    return self.pages;
}

- (NSUInteger)numberOfPages {
    return [[self getPages] count];
}

- (NSData *)dataOfIndex:(NSUInteger)index {
    return [[self getPages][index] data];
}

@end
