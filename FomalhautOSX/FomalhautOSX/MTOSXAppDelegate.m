//
//  MTOSXAppDelegate.m
//  FomalhautOSX
//
//  Created by User on 12/30/13.
//  Copyright (c) 2013 mtgto. All rights reserved.
//

#import "MTOSXAppDelegate.h"
#import "MTOSXMainWindowController.h"
#import "MTAcknowledgementWindowController.h"

extern NSString *const SERVER_INT_PORT_CONFIG_KEY;
extern NSString *const SERVER_BOOL_HTTPS_CONFIG_KEY;
extern NSString *const SERVER_BOOL_START_ON_LAUNCH_CONFIG_KEY;
extern NSString *const HELPER_INOUT_INT_INDEX;
extern NSString *const HELPER_VIEWER_INT_INDEX;

@interface MTOSXAppDelegate()
@property (strong) MTOSXMainWindowController *mainWindowController;
@property (strong) MTAcknowledgementWindowController *acknowledgementWindowController;
@end

@implementation MTOSXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"formalhaut.sqlite3"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{SERVER_INT_PORT_CONFIG_KEY: @(25491),
                                 SERVER_BOOL_HTTPS_CONFIG_KEY: @(YES),
                                 SERVER_BOOL_START_ON_LAUNCH_CONFIG_KEY: @(NO),
                                 HELPER_INOUT_INT_INDEX: @(0),
                                 HELPER_VIEWER_INT_INDEX: @(0)}];
    if ([defaults boolForKey:SERVER_BOOL_START_ON_LAUNCH_CONFIG_KEY]) {
        self.startServerMenuItem.state = NSOnState;
        [self startServer];
    }
    self.mainWindowController = [[MTOSXMainWindowController alloc] initWithWindowNibName:@"MTOSXMainWindowController"];
    [self.mainWindowController showWindow:self];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)toggleServer:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    if (item.state == NSOnState) {
        [self.server stop];
        item.state = NSOffState;
    } else {
        [self startServer];
        item.state = NSOnState;
    }
}

- (void)startServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UInt16 port = (UInt16)[defaults integerForKey:SERVER_INT_PORT_CONFIG_KEY];
    [self.server start:port];
}

- (IBAction)showAcknowledgements:(id)sender {
    self.acknowledgementWindowController = [[MTAcknowledgementWindowController alloc] initWithWindowNibName:@"MTAcknowledgementWindowController"];
    [self.acknowledgementWindowController showWindow:self];
}
@end
