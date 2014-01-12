//
//  MTPDFDocument.m
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

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
