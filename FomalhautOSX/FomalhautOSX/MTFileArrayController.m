//
//  MTFileArrayController.m
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTFileArrayController.h"
#import "NSArray+Function.h"
#import "MTFile.h"

@implementation MTFileArrayController

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.content count];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSPasteboard *pasteboard = [info draggingPasteboard];
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @(YES)};
        NSArray *files = [[pasteboard readObjectsForClasses:@[[NSURL class]] options:options] mapWithBlocks:^id(id obj, NSUInteger index) {
            NSURL *fileURL = (NSURL *)obj;
            MTFile *file = [MTFile MR_createEntity];
            file.name = [fileURL lastPathComponent];
            file.uri = [fileURL absoluteString];
            return file;
        }];
        [self insertObjects:files atArrangedObjectIndexes:[NSIndexSet indexSetWithIndex:row]];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        return YES;
    }
    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    if ([[[info draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

@end
