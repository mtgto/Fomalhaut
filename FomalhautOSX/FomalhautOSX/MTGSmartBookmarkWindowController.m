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

#import "MTGSmartBookmarkWindowController.h"
#import "MTGSmartBookmark.h"

@interface MTGSmartBookmarkWindowController ()

@property (strong) IBOutlet NSObjectController *bookmarkController;

@end

@implementation MTGSmartBookmarkWindowController

- (id)init
{
    return [super initWithWindowNibName:@"MTGSmartBookmarkWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.bookmarkController setManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
}

- (IBAction)pushAdd:(id)sender {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self close];
}

- (IBAction)pushCancel:(id)sender {
    [self close];
}

@end
