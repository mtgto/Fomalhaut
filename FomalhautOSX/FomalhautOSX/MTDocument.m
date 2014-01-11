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

@interface MTDocument()

@property (nonatomic, strong) ZZArchive *archive;
@property (nonatomic, strong) NSArray *entries;

- (NSArray *)getSortedEntries;

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

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowContror
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    return YES;
}

- (NSArray *)getSortedEntries {
    if (self.entries) {
        return self.entries;
    }
    self.entries = [[self.archive.entries withFilterBlock:^BOOL(id obj) {
        ZZArchiveEntry *entry = (ZZArchiveEntry *)obj;
        return [entry.fileName hasSuffix:@".jpg"] || [entry.fileName hasSuffix:@".png"];
    } mapBlock:^id(id obj) {
        return obj;
    }] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ZZArchiveEntry *entry1 = (ZZArchiveEntry *)obj1;
        ZZArchiveEntry *entry2 = (ZZArchiveEntry *)obj2;
        return [entry1.fileName compare:entry2.fileName options:NSNumericSearch];
    }];
    return self.entries;
}

#pragma -

- (NSUInteger)numberOfPages {
    return [[self getSortedEntries] count];
}

- (NSData *)dataOfIndex:(NSUInteger)index {
    return [[self getSortedEntries][index] data];
}

@end
