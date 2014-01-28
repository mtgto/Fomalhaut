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

#import "MTHelpersController.h"
#import "NSArray+Function.h"
#import "MTHelper.h"

extern NSString *const HELPER_TYPE;
extern NSString *const FILE_VIEW_HELPER_CONFIG_KEY;

@implementation MTHelpersController

- (IBAction)addHelper:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setCanCreateDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSArray *helpers = [[panel URLs] mapWithBlocks:^id(id obj) {
            NSString *identifier = [[NSBundle bundleWithURL:obj] bundleIdentifier];
            return [[MTHelper alloc] initWithApplicationIdentifier:identifier];
        }];
        [self addObjects:helpers];
        NSArray *helperIdentifiers = [[self arrangedObjects] mapWithBlocks:^id(id obj) {
            return ((MTHelper *)obj).applicationIdentifier;
        }];
        [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:helperIdentifiers
                                                                            forKey:FILE_VIEW_HELPER_CONFIG_KEY];
    }
}

- (IBAction)removeHelper:(id)sender {
    [self removeObjectAtArrangedObjectIndex:[self selectionIndex]];
    NSArray *helperIdentifiers = [[self arrangedObjects] mapWithBlocks:^id(id obj) {
        return ((MTHelper *)obj).applicationIdentifier;
    }];
    [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:helperIdentifiers
                                                                        forKey:FILE_VIEW_HELPER_CONFIG_KEY];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.content count];
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
    } else if ([[pasteboard types] containsObject:HELPER_TYPE]) {
        return YES;
    }
    return NO;
}

- (BOOL)canDropURL:(NSURL *)url {
    // TODO: refactor
    return [[NSWorkspace sharedWorkspace] isFilePackageAtPath:[url path]] && [[url pathExtension] isEqualToString:@"app"];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    if (operation == NSTableViewDropOn) {
        // you can drop between rows only (cannot drop on the row).
        return NO;
    }
    NSPasteboard *pasteboard = [info draggingPasteboard];
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @(YES)};
        NSArray *helpers = [[[pasteboard readObjectsForClasses:@[[NSURL class]] options:options] withFilterBlock:^BOOL(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [self canDropURL:fileURL];
        } mapBlock:^id(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            return [[MTHelper alloc] initWithApplicationIdentifier:[[NSBundle bundleWithURL:fileURL] bundleIdentifier]];
        }] withFilterBlock:^BOOL(id obj) {
            return [[self arrangedObjects] indexOfObject:obj] == NSNotFound;
        } mapBlock:^id(id obj) {
            return obj;
        }];
        if ([helpers count]) {
            [self insertObjects:helpers atArrangedObjectIndexes:[NSIndexSet indexSetWithIndex:row]];
            NSArray *helperIdentifiers = [[self arrangedObjects] mapWithBlocks:^id(id obj) {
                return ((MTHelper *)obj).applicationIdentifier;
            }];
            [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:helperIdentifiers
                                                                                forKey:FILE_VIEW_HELPER_CONFIG_KEY];
        }
        return YES;
    } else if ([[pasteboard types] containsObject:HELPER_TYPE]) {
        NSData* data = [pasteboard dataForType:HELPER_TYPE];
        NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSInteger destRow = [rowIndexes firstIndex] < row ? row - [rowIndexes count] : row;
        NSArray *helpers = [[self arrangedObjects] objectsAtIndexes:rowIndexes];
        [self removeObjectsAtArrangedObjectIndexes:rowIndexes];
        [self insertObjects:helpers atArrangedObjectIndexes:[NSIndexSet indexSetWithIndex:destRow]];
        NSArray *helperIdentifiers = [[self arrangedObjects] mapWithBlocks:^id(id obj) {
            return ((MTHelper *)obj).applicationIdentifier;
        }];
        [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:helperIdentifiers
                                                                            forKey:FILE_VIEW_HELPER_CONFIG_KEY];
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
        if ([[[info draggingPasteboard] types] containsObject:HELPER_TYPE]) {
            return NSDragOperationMove;
        } else {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:@[HELPER_TYPE] owner:self];
    [pboard setData:data forType:HELPER_TYPE];
    return YES;
}

@end
