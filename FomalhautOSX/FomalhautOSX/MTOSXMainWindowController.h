//
//  MTOSXMainWindowController.h
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

@import Cocoa;
#import "MTFileArrayController.h"

@interface MTOSXMainWindowController : NSWindowController <NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (strong) IBOutlet MTFileArrayController *fileArrayController;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSOutlineView *bookmarkOutlineView;

@end
