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

@interface MTDocument()

@property (nonatomic, strong) ZZArchive *archive;
@property (nonatomic, strong) NSArray *entries;

- (NSArray *)getPages;

@end

@implementation MTDocument

- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self.archive = [ZZArchive archiveWithContentsOfURL:url];
        //self.displayName = [url lastPathComponent];
        [self setFileURL:url];
    }
    return self;
}

- (void)makeWindowControllers
{
    MTBookWindowController *windowController = [[MTBookWindowController alloc] initWithWindowNibName:@"MTBookWindowController"];
    [self addWindowController:windowController];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    return YES;
}

- (NSArray *)getPages {
    if (self.entries) {
        return self.entries;
    }
    self.entries = [[self.archive.entries withFilterBlock:^BOOL(id obj) {
        ZZArchiveEntry *entry = (ZZArchiveEntry *)obj;
        NSString *fileName = [entry.fileName lowercaseString];
        return [fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".png"];
    } mapBlock:^id(id obj) {
        ZZArchiveEntry *entry = (ZZArchiveEntry *)obj;
        return [[MTZipEntryPage alloc] initWithZipEntry:entry];
    }] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MTZipEntryPage *page1 = (MTZipEntryPage *)obj1;
        MTZipEntryPage *page2 = (MTZipEntryPage *)obj2;
        return [page1.fileName compare:page2.fileName options:NSNumericSearch];
    }];
    return self.entries;
}

#pragma -

- (NSUInteger)numberOfPages {
    return [[self getPages] count];
}

- (NSData *)dataOfIndex:(NSUInteger)index {
    return [[self getPages][index] data];
}

@end
