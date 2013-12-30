//
//  MTOSXAppDelegate.m
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTOSXAppDelegate.h"
#import "MTOSXMainWindowController.h"

@interface MTOSXAppDelegate()
@property (strong) MTOSXMainWindowController *mainWindowController;
@end

@implementation MTOSXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"formalhaut.sqlite3"];
    self.mainWindowController = [[MTOSXMainWindowController alloc] initWithWindowNibName:@"MTOSXMainWindowController"];
    [self.mainWindowController showWindow:self];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}

@end
