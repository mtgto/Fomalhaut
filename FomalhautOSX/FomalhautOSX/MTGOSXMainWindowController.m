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

#import "MTGOSXMainWindowController.h"
#import "MTGFile+Addition.h"
#import "MTGDocument.h"
#import "MTBookmark.h"
#import "MTGBookmarkAll.h"
#import "MTGBookmarkUnread.h"
#import "NSArray+Function.h"
#import "MTGNormalBookmark.h"
#import "MTGSmartBookmark.h"
#import "MTGSmartBookmarkWindowController.h"
#import "MTGZeroWidthSplitView.h"
@import Quartz;
#import "MTGHelper.h"

extern NSString *const SERVER_INT_PORT_CONFIG_KEY;
extern NSString *const SERVER_BOOL_HTTPS_CONFIG_KEY;
extern NSString *const SERVER_BOOL_START_ON_LAUNCH_CONFIG_KEY;
extern NSString *const HELPER_INOUT_INT_INDEX;
extern NSString *const HELPER_VIEWER_INT_INDEX;
extern NSString *const FILE_TYPE;
extern NSString *const FILE_VIEW_TYPE_CONFIG_KEY;
extern NSString *const FILE_VIEW_HELPER_CONFIG_KEY;

@interface MTGOSXMainWindowController ()
@property (strong) IBOutlet NSTreeController *bookmarkTreeController;

@property (strong) IBOutlet MTGSmartBookmarkWindowController *smartBookmarkWindowController;

@property (nonatomic, strong) NSArray *topLevelItems;

/**
 * Predefined bookmarks. currently there are two bookmarks: "All", "Unread"
 */
@property (nonatomic, strong) NSArray *fixedBookmarks;

/**
 * Array of MTNormalBookmark.
 */
@property (nonatomic, strong) NSArray *normalBookmarks;

@property (nonatomic, strong) NSArray *smartBookmarks;

@property (strong) IBOutlet NSMenu *fileMenu;

@property (weak) IBOutlet NSMenuItem *helpersMenuItem;

@property (strong) IBOutlet NSMenu *normalBookmarkMenu;

@property (strong) IBOutlet NSMenu *smartBookmarkMenu;

@property (weak) IBOutlet NSClipView *mainClipView;

@property (strong) IBOutlet IKImageBrowserView *thumbnailBrowserView;

@property (strong) IBOutlet NSTableHeaderView *tableHeaderView;

- (void)openFile:(MTGFile *)files;

- (void)openFileWithInternalViewer:(MTGFile *)file;

- (void)openFile:(MTGFile *)file withApplicationIdentifier:(NSString *)applicationIdentifier;

@end

@implementation MTGOSXMainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.topLevelItems = @[@"Library", @"Bookmarks"];
        self.fixedBookmarks = @[[MTGBookmarkAll sharedInstance], [MTGBookmarkUnread sharedInstance]];
        self.normalBookmarks = [MTGNormalBookmark MR_findAllSortedBy:@"name" ascending:YES];
        self.smartBookmarks = [MTGSmartBookmark MR_findAllSortedBy:@"name" ascending:YES];
        [self.window setExcludedFromWindowsMenu:YES];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.fileArrayController setManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    if ([defaults integerForKey:FILE_VIEW_TYPE_CONFIG_KEY] == 0) {
        [self.mainClipView setDocumentView:self.tableView];
    } else {
        [self.tableView setHeaderView:nil];
        [self.mainClipView setDocumentView:self.thumbnailBrowserView];
    }
    [self.tableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationAll forLocal:NO];
    [self.thumbnailBrowserView registerForDraggedTypes:@[FILE_TYPE]];
    [self.bookmarkOutlineView registerForDraggedTypes:@[FILE_TYPE]];
    self.bookmarkOutlineView.smartBookmarkMenu = self.smartBookmarkMenu;
    self.bookmarkOutlineView.normalBookmarkMenu = self.normalBookmarkMenu;
    [self.bookmarkOutlineView expandItem:nil expandChildren:YES];
    NSInteger row = [self.bookmarkOutlineView rowForItem:[self.fixedBookmarks firstObject]];
    if (row >= 0) {
        [self.bookmarkOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:YES];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managedObjectChanged:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    [self.window setExcludedFromWindowsMenu:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:nil];
}

- (void)doubleClicked:(NSArray *)selectedObjects {
    if ([selectedObjects count]) {
        [self openFile:selectedObjects[0]];
    }
}

- (void)openFile:(MTGFile *)file {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSURL URLWithString:file.url] path]]) {
        file.isLost = YES;
        NSAlert *alert = [NSAlert alertWithMessageText:nil
                                         defaultButton:NSLocalizedString(@"TEXT_CHOOSE_FILE", nil)
                                       alternateButton:NSLocalizedString(@"TEXT_CANCEL", nil)
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"ALERT_CHOOSE_DEST_FOR_LOST_FILE_TITLE_FORMAT", nil), file.name];
        if ([alert runModal] == NSAlertDefaultReturn) {
            NSOpenPanel *panel = [NSOpenPanel openPanel];
            [panel setCanChooseDirectories:NO];
            [panel setAllowsMultipleSelection:NO];
            // TODO: auto generate or retrive from current application.
            [panel setAllowedFileTypes:@[@"zip", @"cbz", @"pdf"]];
            if ([panel runModal] == NSFileHandlingPanelOKButton) {
                if ([panel.URLs count]) {
                    NSURL *url = panel.URLs[0];
                    file.url = [url absoluteString];
                    file.name = [url lastPathComponent];
                    file.isLost = NO;
                }
            }
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } else {
        BOOL useInternalViewer = [defaults integerForKey:HELPER_INOUT_INT_INDEX] == 0;
        NSString *helperApplicationIdentifier = nil;
        if (!useInternalViewer) {
            NSArray *helperApplicationIdenfiers = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:FILE_VIEW_HELPER_CONFIG_KEY];
            if ([helperApplicationIdenfiers count]) {
                helperApplicationIdentifier = helperApplicationIdenfiers[0];
            }
        }
        if (helperApplicationIdentifier) {
            [self openFile:file withApplicationIdentifier:helperApplicationIdentifier];
        } else {
            [self openFileWithInternalViewer:file];
        }
    }
}

- (void)openFileWithInternalViewer:(MTGFile *)file {
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL URLWithString:file.url]
                                                                           display:YES
                                                                 completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                                                                     if (error) {
                                                                         NSAlert *alert = [NSAlert alertWithError:error];
                                                                         [alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
                                                                     } else if (!documentWasAlreadyOpen) {
                                                                         if (!file.thumbnailData && [(MTGDocument *)document numberOfPages]) {
                                                                             file.thumbnailData = [(MTGDocument *)document dataOfIndex:0 withSize:CGSizeMake(128, 128)];
                                                                         }
                                                                         file.readCount++;
                                                                         file.lastOpened = [NSDate timeIntervalSinceReferenceDate];
                                                                         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                                                     }
                                                                 }];
}

- (void)openFile:(MTGFile *)file withApplicationIdentifier:(NSString *)applicationIdentifier {
    NSURL *url = [NSURL URLWithString:file.url];
    if ([[NSWorkspace sharedWorkspace] openURLs:@[url] withAppBundleIdentifier:applicationIdentifier options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL]) {
        file.readCount++;
        file.lastOpened = [NSDate timeIntervalSinceReferenceDate];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:nil defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"ALERT_FAIL_TO_OPEN_WITH_EXTERNAL_APP_TITLE", nil)];
        [alert runModal];
    }
}

/**
 * Array of MTFile which chosen in table view.
 */
- (NSArray *)clickedItems {
    NSInteger row = [self.tableView clickedRow];
    if (row >= 0) {
        if ([[self.tableView selectedRowIndexes] containsIndex:row]) {
            return [self.fileArrayController selectedObjects];
        } else {
            return @[[self.fileArrayController arrangedObjects][row]];
        }
    } else {
        return [self.fileArrayController selectedObjects];
    }

}

#pragma mark - IBOutlet
- (IBAction)open:(id)sender {
    NSArray *files = [self clickedItems];
    if ([files count]) {
        [self openFile:files[0]];
    }
}

- (void)openWithHelper:(id)sender {
    NSArray *files = [self clickedItems];
    NSString *applicationIdentifier = [sender representedObject];
    if ([files count] && applicationIdentifier) {
        [self openFile:files[0] withApplicationIdentifier:applicationIdentifier];
    }
}

- (IBAction)delete:(id)sender {
    NSArray *files = [self clickedItems];
    for (MTGFile *file in files) {
        [file MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (IBAction)addNewNormalBookmark:(id)sender {
    MTGNormalBookmark *bookmark = [MTGNormalBookmark MR_createEntity];
    // TODO make unique name
    bookmark.name = @"New Bookmark";
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}

- (IBAction)deleteNormalBookmark:(id)sender {
    NSInteger row = [self.bookmarkOutlineView selectedRow];
    if (row >= 0) {
        id item = [self.bookmarkOutlineView itemAtRow:row];
        if ([item isKindOfClass:[MTGNormalBookmark class]]) {
            MTGNormalBookmark *bookmark = (MTGNormalBookmark *)item;
            [bookmark MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
}

- (IBAction)addNewSmartBookmark:(id)sender {
    MTGSmartBookmark *bookmark = [MTGSmartBookmark MR_createEntity];
    bookmark.name = @"New smart bookmark";
    bookmark.predicate = [NSPredicate predicateWithFormat:@"name contains ''"];
    self.smartBookmarkWindowController.bookmark = bookmark;
    [self.smartBookmarkWindowController showWindow:self];
}

- (IBAction)editSmartBookmark:(id)sender {
    NSInteger row = [self.bookmarkOutlineView selectedRow];
    if (row >= 0) {
        id item = [self.bookmarkOutlineView itemAtRow:row];
        if ([item isKindOfClass:[MTGSmartBookmark class]]) {
            MTGSmartBookmark *bookmark = (MTGSmartBookmark *)item;
            self.smartBookmarkWindowController.bookmark = bookmark;
            [self.smartBookmarkWindowController showWindow:self];
        }
    }
}

- (IBAction)deleteSmartBookmark:(id)sender {
    NSInteger row = [self.bookmarkOutlineView selectedRow];
    if (row >= 0) {
        id item = [self.bookmarkOutlineView itemAtRow:row];
        if ([item isKindOfClass:[MTGSmartBookmark class]]) {
            MTGSmartBookmark *bookmark = (MTGSmartBookmark *)item;
            [bookmark MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
}

- (IBAction)changeFileView:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    if (segmentedControl.selectedSegment == 0) {
        [self.mainClipView setDocumentView:self.tableView];
        [self.tableView setHeaderView:self.tableHeaderView];
        [self.tableView scrollRowToVisible:0];
    } else {
        [self.tableView setHeaderView:nil];
        [self.mainClipView setDocumentView:self.thumbnailBrowserView];
        [self.thumbnailBrowserView scrollIndexToVisible:0];
    }
    [self.mainClipView setNeedsDisplayInRect:[self.mainClipView frame]];
}


#pragma mark - NSOutlineViewDataSource

- (NSArray *)_childrenForItem:(id)item {
    if (item == nil) {
        return self.topLevelItems;
    } else if ([item isEqual:@"Library"]) {
        return self.fixedBookmarks;
    } else if ([item isEqual:@"Bookmarks"]) {
        return [self.normalBookmarks arrayByAddingObjectsFromArray:self.smartBookmarks];
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

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index {
    if ([item isKindOfClass:[MTGNormalBookmark class]]) {
        MTGNormalBookmark *bookmark = (MTGNormalBookmark *)item;
        NSPasteboard *pasteboard = [info draggingPasteboard];
        NSSet *fileUuids = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:FILE_TYPE]];
        NSMutableSet *fileSet = [NSMutableSet setWithCapacity:[fileUuids count]];
        [fileUuids enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [fileSet addObject:[MTGFile MR_findFirstByAttribute:@"uuid" withValue:obj]];
        }];
        [bookmark addEntries:fileSet];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        return YES;
    }
    return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if ([item isKindOfClass:[MTGNormalBookmark class]]) {
        return NSDragOperationMove;
    } else {
        return NSDragOperationNone;
    }
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
        [view.textField setEditable:NO];
        return view;
    } else {
        // The cell is setup in IB. The textField and imageView outlets are properly setup.
        // Special attributes are automatically applied by NSTableView/NSOutlineView for the source list
        NSTableCellView *view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        if ([item isKindOfClass:[MTGNormalBookmark class]]) {
            MTGNormalBookmark *bookmark = (MTGNormalBookmark *)item;
            view.menu = nil;
            view.textField.stringValue = bookmark.name;
            [view.textField setEditable:YES];
            view.imageView.image = [NSImage imageNamed:NSImageNameBookmarksTemplate];
        } else {
            if ([item isKindOfClass:[MTGSmartBookmark class]]) {
                view.menu = self.smartBookmarkMenu;
            } else {
                view.menu = nil;
            }
            NSObject<MTGBookmark> *bookmark = (NSObject<MTGBookmark> *)item;
            view.textField.stringValue = [bookmark displayName];
            [view.textField setEditable:NO];
            // Setup the icon based on our section
            id parent = [outlineView parentForItem:item];
            NSInteger index = [_topLevelItems indexOfObject:parent];
            switch (index) {
                case 0: {
                    view.imageView.image = [NSImage imageNamed:NSImageNameBookmarksTemplate];
                    break;
                }
                case 1: {
                    view.imageView.image = [NSImage imageNamed:NSImageNameFolderSmart];
                    break;
                }
            }
        }
        return view;
    }
}

// TODO use NSTreeController
//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
//    return [item isKindOfClass:[MTNormalBookmark class]];
//}
//
//- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
//    
//}
//
//- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
//    return YES;
//}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    id item = [self.bookmarkOutlineView itemAtRow:self.bookmarkOutlineView.selectedRow];
    if ([item isKindOfClass:[MTGNormalBookmark class]]) {
        MTGNormalBookmark *bookmark = (MTGNormalBookmark *)item;
        [self.fileArrayController setContent:bookmark.entries];
//        [self.bookmarkOutlineView editColumn:0 row:self.bookmarkOutlineView.selectedRow withEvent:nil select:YES];
    } else {
        NSObject<MTGBookmark> *bookmark = (NSObject<MTGBookmark> *)item;
        [self.fileArrayController setFetchPredicate:[bookmark predicate]];
    }
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    id item = [self.bookmarkOutlineView itemAtRow:self.bookmarkOutlineView.selectedRow];
    if ([item isKindOfClass:[MTGNormalBookmark class]]) {
        MTGNormalBookmark *bookmark = (MTGNormalBookmark *)item;
        bookmark.name = control.stringValue;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    return YES;
}

#pragma mark - Notification

- (void)managedObjectChanged:(NSNotification *)notification {
    DDLogDebug(@"managedObjectChanged: %@", [notification userInfo]);
    self.normalBookmarks = [MTGNormalBookmark MR_findAllSortedBy:@"name" ascending:YES];
    self.smartBookmarks = [MTGSmartBookmark MR_findAllSortedBy:@"name" ascending:YES];
    [self.bookmarkOutlineView reloadData];
    [self.thumbnailBrowserView reloadData];
}

#pragma mark - IKImageBrowserDelegate (informally defined)

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index {
    MTGFile *file = [self.fileArrayController arrangedObjects][index];
    [self openFile:file];
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event {
    [NSMenu popUpContextMenu:self.fileMenu withEvent:event forView:aBrowser];
}

#pragma mark - NSSplitViewDelegate

//- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
//    if (dividerIndex == 1) {
//        return 0.0;
//    } else {
//        return 10000;
//    }
//}

#pragma mark - NSMenuDelegate

// update for file menu
- (void)menuNeedsUpdate:(NSMenu *)menu {
    NSMenu *helpers = [[NSMenu alloc] init];
    NSArray *helperApplicationIdenfiers = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:FILE_VIEW_HELPER_CONFIG_KEY];
    if ([helperApplicationIdenfiers count]) {
        for (NSString *identifier in helperApplicationIdenfiers) {
            MTGHelper *helper = [[MTGHelper alloc] initWithApplicationIdentifier:identifier];
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:helper.name action:@selector(openWithHelper:) keyEquivalent:@""];
            [item setRepresentedObject:identifier];
            [helpers addItem:item];
        }
        [self.helpersMenuItem setEnabled:YES];
    } else {
        [self.helpersMenuItem setEnabled:NO];
    }
    [self.helpersMenuItem setSubmenu:helpers];
}

@end
