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
    if (![[NSFileManager defaultManager] fileExistsAtPath:[absoluteURL path]]) {
        return NO;
    }
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
