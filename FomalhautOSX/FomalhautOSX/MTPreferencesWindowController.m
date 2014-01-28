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

#import "MTPreferencesWindowController.h"
#import "MTHelpersController.h"
#import "MTHelper.h"
#import "NSArray+Function.h"

extern NSString *const SERVER_INT_PORT_CONFIG_KEY;
extern NSString *const SERVER_BOOL_HTTPS_CONFIG_KEY;
extern NSString *const SERVER_BOOL_START_ON_LAUNCH_CONFIG_KEY;
extern NSString *const HELPER_TYPE;
extern NSString *const FILE_VIEW_HELPER_CONFIG_KEY;

@interface MTPreferencesWindowController ()

@property (strong) IBOutlet MTHelpersController *helpersController;
@property (weak) IBOutlet NSTableView *helperTableView;

@end

@implementation MTPreferencesWindowController

- (id)init
{
    return [super initWithWindowNibName:@"MTPreferencesWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.helperTableView registerForDraggedTypes:@[NSFilenamesPboardType, HELPER_TYPE]];
    NSArray *helpers = [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:FILE_VIEW_HELPER_CONFIG_KEY] mapWithBlocks:^id(id obj) {
        return [[MTHelper alloc] initWithApplicationIdentifier:obj];
    }];
    [self.helpersController setContent:[NSMutableArray arrayWithArray:helpers]];
}

@end
