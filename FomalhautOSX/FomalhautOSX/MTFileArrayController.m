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

@interface MTFileArrayController()

@property (nonatomic, strong) NSSet *availableFileExtensions;

@end

@implementation MTFileArrayController

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.content count];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSPasteboard *pasteboard = [info draggingPasteboard];
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
        if (!self.availableFileExtensions) {
            // TODO: auto generate or retrive from current application.
            self.availableFileExtensions = [NSSet setWithObjects:@"zip", @"cbz", @"pdf", nil];
        }
        NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @(YES)};
        NSArray *files = [[pasteboard readObjectsForClasses:@[[NSURL class]] options:options] withFilterBlock:^BOOL(id obj) {
            NSURL *fileURL = (NSURL *)obj;
            NSString *pathExtension = [[fileURL pathExtension] lowercaseString];
            if (![self.availableFileExtensions containsObject:pathExtension]) {
                return NO;
            }
            if ([MTFile MR_findFirstByAttribute:@"uri" withValue:[fileURL absoluteString]]) {
                return NO;
            }
            return YES;
        } mapBlock:^id(id obj) {
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
        NSArray *files = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

@end
