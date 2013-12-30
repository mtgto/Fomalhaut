//
//  MTOSXMainWindowController.h
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

@import Cocoa;

@interface MTOSXMainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSArrayController *fileArrayController;

@end
