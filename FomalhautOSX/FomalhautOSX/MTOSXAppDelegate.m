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
