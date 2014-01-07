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

@interface MTOSXMainWindowController ()

@property (nonatomic, strong) MTWebServer *server;

@end

@implementation MTOSXMainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.server = [[MTWebServer alloc] init];
        [self.server start];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.fileArrayController setManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    [self.tableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationAll forLocal:NO];
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

@end
