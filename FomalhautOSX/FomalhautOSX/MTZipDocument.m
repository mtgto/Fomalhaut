//
//  MTZipDocument.m
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTZipDocument.h"
#import <zipzap/zipzap.h>
#import "NSArray+Function.h"
#import "MTZipEntryPage.h"

@interface MTZipDocument()

@property (nonatomic, strong) ZZArchive *archive;
@property (nonatomic, strong) NSArray *entries;

@end

@implementation MTZipDocument

- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    self = [super initWithContentsOfURL:url ofType:typeName error:outError];
    if (self) {
        // Add your subclass-specific initialization here.
        self.archive = [[ZZArchive alloc] initWithContentsOfURL:url encoding:NSShiftJISStringEncoding];
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

- (NSUInteger)numberOfPages {
    return [[self getPages] count];
}

- (NSData *)dataOfIndex:(NSUInteger)index {
    return [[self getPages][index] data];
}

@end
