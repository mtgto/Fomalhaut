//
//  MTOSXMainWindowController.m
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTOSXMainWindowController.h"
#import "MTFile.h"
#import "MTDocument.h"
#import "MTBookmark.h"
#import "MTBookmarkAll.h"
#import "MTBookmarkUnread.h"
#import "NSArray+Function.h"

extern NSString *const SERVER_INT_PORT_CONFIG_KEY;
extern NSString *const SERVER_BOOL_HTTPS_CONFIG_KEY;
extern NSString *const SERVER_BOOL_START_ON_LAUNCH_CONFIG_KEY;
extern NSString *const HELPER_INOUT_INT_INDEX;
extern NSString *const HELPER_VIEWER_INT_INDEX;
extern NSString *const HELPER_VIEWER_APP_ID_MANGAO;
extern NSString *const HELPER_VIEWER_APP_ID_MANGAO_KAI;
extern NSString *const HELPER_VIEWER_APP_ID_SIMPLE_COMIC;


@interface MTOSXMainWindowController ()

@property (nonatomic, strong) NSArray *topLevelItems;

@property (nonatomic, strong) NSArray *bookmarks;

- (void)openFiles:(NSArray *)files;

- (void)openFilesWithInternalViewer:(NSArray *)files;

- (void)openFiles:(NSArray *)files withApplicationIdentifier:(NSString *)applicationIdentifier;

@end

@implementation MTOSXMainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
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
    [self openFiles:selectedObjects];
}

- (void)openFiles:(NSArray *)files {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL useInternalViewer = [defaults integerForKey:HELPER_INOUT_INT_INDEX] == 0;
    if (useInternalViewer) {
        [self openFilesWithInternalViewer:files];
    } else {
        NSString *appIdentifier = @[HELPER_VIEWER_APP_ID_MANGAO, HELPER_VIEWER_APP_ID_MANGAO_KAI, HELPER_VIEWER_APP_ID_SIMPLE_COMIC][[defaults integerForKey:HELPER_VIEWER_INT_INDEX]];
        [self openFiles:files withApplicationIdentifier:appIdentifier];
    }
}

- (void)openFilesWithInternalViewer:(NSArray *)files {
    for (MTFile *file in files) {
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL URLWithString:file.url]
                                                                               display:YES
                                                                     completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                                                                         if (error) {
                                                                             NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ALERT_FAIL_TO_OPEN_TITLE", nil) defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
                                                                             [alert runModal];
                                                                         } else if (!documentWasAlreadyOpen) {
                                                                             file.readCount++;
                                                                             file.lastOpened = [NSDate timeIntervalSinceReferenceDate];
                                                                             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                                                         }
                                                                     }];
    }
}

- (void)openFiles:(NSArray *)files withApplicationIdentifier:(NSString *)applicationIdentifier {
    NSArray *urls = [files mapWithBlocks:^id(id obj) {
        return [NSURL URLWithString:((MTFile *)obj).url];
    }];
    if ([[NSWorkspace sharedWorkspace] openURLs:urls withAppBundleIdentifier:applicationIdentifier options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL]) {
        for (MTFile *file in files) {
            file.readCount++;
            file.lastOpened = [NSDate timeIntervalSinceReferenceDate];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ALERT_FAIL_TO_OPEN_WITH_EXTERNAL_APP_TITLE", nil) defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    }
}

#pragma mark - IBOutlet
- (IBAction)open:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row >= 0) {
        if ([[self.tableView selectedRowIndexes] containsIndex:row]) {
            [self openFiles:[self.fileArrayController selectedObjects]];
        } else {
            [self openFiles:@[[self.fileArrayController arrangedObjects][row]]];
        }
    }
}

- (IBAction)openWithMangao:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row >= 0) {
        if ([[self.tableView selectedRowIndexes] containsIndex:row]) {
            [self openFiles:[self.fileArrayController selectedObjects] withApplicationIdentifier:HELPER_VIEWER_APP_ID_MANGAO];
        } else {
            [self openFiles:@[[self.fileArrayController arrangedObjects][row]] withApplicationIdentifier:HELPER_VIEWER_APP_ID_MANGAO];
        }
    }
}

- (IBAction)openWithMangaoKai:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row >= 0) {
        if ([[self.tableView selectedRowIndexes] containsIndex:row]) {
            [self openFiles:[self.fileArrayController selectedObjects] withApplicationIdentifier:HELPER_VIEWER_APP_ID_MANGAO_KAI];
        } else {
            [self openFiles:@[[self.fileArrayController arrangedObjects][row]] withApplicationIdentifier:HELPER_VIEWER_APP_ID_MANGAO_KAI];
        }
    }
}

- (IBAction)openWithSimpleComic:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row >= 0) {
        if ([[self.tableView selectedRowIndexes] containsIndex:row]) {
            [self openFiles:[self.fileArrayController selectedObjects] withApplicationIdentifier:HELPER_VIEWER_APP_ID_SIMPLE_COMIC];
        } else {
            [self openFiles:@[[self.fileArrayController arrangedObjects][row]] withApplicationIdentifier:HELPER_VIEWER_APP_ID_SIMPLE_COMIC];
        }
    }
}

- (IBAction)delete:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row >= 0) {
        if ([[self.tableView selectedRowIndexes] containsIndex:row]) {
            [self.fileArrayController removeObjectsAtArrangedObjectIndexes:[self.tableView selectedRowIndexes]];
        } else {
            [self.fileArrayController removeObjectAtArrangedObjectIndex:row];
        }
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
