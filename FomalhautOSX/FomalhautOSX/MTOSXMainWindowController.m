//
//  MTOSXMainWindowController.m
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTOSXMainWindowController.h"
#import "MTFile.h"
#import "MTWebServer.h"
#import "MTDocument.h"
#import "MTBookmark.h"
#import "MTBookmarkAll.h"
#import "MTBookmarkUnread.h"

@interface MTOSXMainWindowController ()

@property (nonatomic, strong) MTWebServer *server;

@property (nonatomic, strong) NSArray *topLevelItems;

@property (nonatomic, strong) NSArray *bookmarks;

@end

@implementation MTOSXMainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.server = [[MTWebServer alloc] init];
        [self.server start];
        self.topLevelItems = @[@"Library"];
        self.bookmarks = @[[MTBookmarkAll sharedInstance], [MTBookmarkUnread sharedInstance]];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.fileArrayController setManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    [self.tableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationAll forLocal:NO];
    [self.bookmarkOutlineView expandItem:nil expandChildren:YES];
    NSInteger row = [self.bookmarkOutlineView rowForItem:[self.bookmarks firstObject]];
    if (row >= 0) {
        [self.bookmarkOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:YES];
    }
}

- (void)doubleClicked:(NSArray *)selectedObjects {
    for (MTFile *file in selectedObjects) {
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL URLWithString:file.uri]
                                                                               display:YES
                                                                     completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                                                                         if (error) {
                                                                             // TODO show error dialog
                                                                         } else if (!documentWasAlreadyOpen) {
                                                                             file.readCount++;
                                                                             file.lastOpened = [NSDate timeIntervalSinceReferenceDate];
                                                                             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                                                         }
                                                                     }];
    }

}

#pragma mark - NSOutlineViewDataSource

- (NSArray *)_childrenForItem:(id)item {
    if (item == nil) {
        return self.topLevelItems;
    } else if ([item isEqual:@"Library"]) {
        return self.bookmarks;
    } else {
        DDLogError(@"Unsupported item: %@", item);
        return nil;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    return [[self _childrenForItem:item] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [outlineView parentForItem:item] == nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return [[self _childrenForItem:item] count];
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [self.topLevelItems containsObject:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    // ROOT: Show/Hide text
    // CHILD: Right Triangle
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![self.topLevelItems containsObject:item];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // For the groups, we just return a regular text view.
    if ([self.topLevelItems containsObject:item]) {
        NSTableCellView *view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        // Uppercase the string value, but don't set anything else. NSOutlineView automatically applies attributes as necessary
        NSString *value = [item uppercaseString];
        view.textField.stringValue = value;
        return view;
    } else {
        // The cell is setup in IB. The textField and imageView outlets are properly setup.
        // Special attributes are automatically applied by NSTableView/NSOutlineView for the source list
        NSTableCellView *view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        NSObject<MTBookmark> *bookmark = (NSObject<MTBookmark> *)item;
        view.textField.stringValue = [bookmark displayName];
        // Setup the icon based on our section
        id parent = [outlineView parentForItem:item];
        NSInteger index = [_topLevelItems indexOfObject:parent];
        switch (index) {
            case 0: {
                view.imageView.image = [NSImage imageNamed:NSImageNameBookmarksTemplate];
                break;
            }
            case 1: {
                view.imageView.image = [NSImage imageNamed:NSImageNameSmartBadgeTemplate];
                break;
            }
        }
        return view;
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    id item = [self.bookmarkOutlineView itemAtRow:self.bookmarkOutlineView.selectedRow];
    NSObject<MTBookmark> *bookmark = (NSObject<MTBookmark> *)item;
    [self.fileArrayController setFetchPredicate:[bookmark predicate]];
}

@end
