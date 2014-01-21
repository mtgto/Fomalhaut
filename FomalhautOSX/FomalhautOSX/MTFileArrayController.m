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

#import "MTFileArrayController.h"
#import "NSArray+Function.h"
#import "MTFile.h"
#import "MTFile+Addition.h"
@import Quartz;

extern NSString *const FILE_TYPE;

@interface MTFileArrayController()

+ (NSSet *)availableFileExtensions;

@end

@implementation MTFileArrayController

+ (NSSet *)availableFileExtensions {
    static NSSet *_shared;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shared = [NSSet setWithObjects:@"zip", @"cbz", @"pdf", nil];
    });

    return _shared;
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
            NSString *pathExtension = [[fileURL pathExtension] lowercaseString];
            if (![[MTFileArrayController availableFileExtensions] containsObject:pathExtension]) {
                return NO;
            }
            if ([MTFile MR_findFirstByAttribute:@"url" withValue:[fileURL absoluteString]]) {
                return NO;
            }
            return YES;
        } mapBlock:^id(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [MTFile createEntityWithURL:fileURL];
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
    if ([[[info draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
        NSArray *files = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSMutableSet *uuidSet = [NSMutableSet setWithCapacity:[rowIndexes count]];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        MTFile *file = [self arrangedObjects][idx];
        [uuidSet addObject:file.uuid];
    }];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:uuidSet];
    [pboard declareTypes:@[FILE_TYPE] owner:self];
    [pboard setData:data forType:FILE_TYPE];
    return YES;
}

- (NSUInteger)imageBrowser:(IKImageBrowserView *)aBrowser writeItemsAtIndexes:(NSIndexSet *)itemIndexes toPasteboard:(NSPasteboard *)pasteboard {
    NSMutableSet *uuidSet = [NSMutableSet setWithCapacity:[itemIndexes count]];
    [itemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        MTFile *file = [self arrangedObjects][idx];
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
    if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
        NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
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
        NSArray *files = [[pasteboard readObjectsForClasses:@[[NSURL class]] options:options] withFilterBlock:^BOOL(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            NSString *pathExtension = [[fileURL pathExtension] lowercaseString];
            if (![[MTFileArrayController availableFileExtensions] containsObject:pathExtension]) {
                return NO;
            }
            if ([MTFile MR_findFirstByAttribute:@"url" withValue:[fileURL absoluteString]]) {
                return NO;
            }
            return YES;
        } mapBlock:^id(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [MTFile createEntityWithURL:fileURL];
        }];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        return YES;
    }
    return NO;
}

@end
