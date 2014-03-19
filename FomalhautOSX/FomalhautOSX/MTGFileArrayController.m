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

#import "MTGFileArrayController.h"
#import "NSArray+Function.h"
#import "MTGFile.h"
#import "MTGFile+Addition.h"
@import Quartz;

extern NSString *const FILE_TYPE;

@interface MTGFileArrayController()

+ (NSSet *)availableFileExtensions;

/**
 * Check whether at least one file is allowed to be drop.
 */
- (BOOL)canDropDraggingInfo:(id<NSDraggingInfo>)info;

- (BOOL)canDropURL:(NSURL *)url;

@end

@implementation MTGFileArrayController

+ (NSSet *)availableFileExtensions {
    static NSSet *_shared;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shared = [NSSet setWithObjects:@"zip", @"cbz", @"pdf", nil];
    });

    return _shared;
}

- (BOOL)canDropDraggingInfo:(id<NSDraggingInfo>)info {
    NSPasteboard *pasteboard = [info draggingPasteboard];
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @(YES)};
        return NSNotFound != [[pasteboard readObjectsForClasses:@[[NSURL class]] options:options] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSURL *url = (NSURL *)obj;
            if ([self canDropURL:url]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
    }
    return NO;
}

- (BOOL)canDropURL:(NSURL *)url {
    if (![[MTGFileArrayController availableFileExtensions] containsObject:[[url pathExtension] lowercaseString]]) {
        return NO;
    }
    if ([MTGFile MR_findFirstByAttribute:@"url" withValue:[url absoluteString]]) {
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.content count];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    if (operation == NSTableViewDropOn) {
        // you can drop between rows only (cannot drop on the row).
        return NO;
    }
    NSPasteboard *pasteboard = [info draggingPasteboard];
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @(YES)};
        NSArray *files = [[pasteboard readObjectsForClasses:@[[NSURL class]] options:options] withFilterBlock:^BOOL(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [self canDropURL:fileURL];
        } mapBlock:^id(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [MTGFile createEntityWithURL:fileURL];
        }];
        [self insertObjects:files atArrangedObjectIndexes:[NSIndexSet indexSetWithIndex:row]];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        return YES;
    }
    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if (operation == NSTableViewDropOn) {
        // you can drop between rows only (cannot drop on the row).
        return NSDragOperationNone;
    }
    if ([self canDropDraggingInfo:info]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSMutableSet *uuidSet = [NSMutableSet setWithCapacity:[rowIndexes count]];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        MTGFile *file = [self arrangedObjects][idx];
        [uuidSet addObject:file.uuid];
    }];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:uuidSet];
    [pboard declareTypes:@[FILE_TYPE] owner:self];
    [pboard setData:data forType:FILE_TYPE];
    return YES;
}

#pragma mark - IKImageBrowserDataSource

- (NSUInteger)imageBrowser:(IKImageBrowserView *)aBrowser writeItemsAtIndexes:(NSIndexSet *)itemIndexes toPasteboard:(NSPasteboard *)pasteboard {
    NSMutableSet *uuidSet = [NSMutableSet setWithCapacity:[itemIndexes count]];
    [itemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        MTGFile *file = [self arrangedObjects][idx];
        [uuidSet addObject:file.uuid];
    }];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:uuidSet];
    [pasteboard declareTypes:@[FILE_TYPE] owner:self];
    [pasteboard setData:data forType:FILE_TYPE];
    return [uuidSet count];
}

#pragma mark - NSDraggingDestination

/* Drag'n drop support, accept any kind of drop */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([self canDropDraggingInfo:sender]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @(YES)};
        [[pasteboard readObjectsForClasses:@[[NSURL class]] options:options] withFilterBlock:^BOOL(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [self canDropURL:fileURL];
        } mapBlock:^id(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [MTGFile createEntityWithURL:fileURL];
        }];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        return YES;
    }
    return NO;
}

@end
